'use client'
import { useEffect, useMemo, useRef, useState } from 'react'
import * as nacl from 'tweetnacl'
import { set, get } from 'idb-keyval'
import { importAesKeyFromRaw, sha256, aesEncrypt, aesDecrypt } from '../lib/crypto'

type Msg = { id:string; user:string; text?:string; ts:number; attachments?:{name:string,url:string, iv?:string}[]; cipher?:string; nonce?:string; }
const WS_URL = (typeof window!=='undefined' ? (window.location.origin.replace(/^http/,'ws') + '/ws') : '')
const API = (typeof window!=='undefined' ? (window.location.origin + '/api/chat') : '')

function bufToBase64(buf: Uint8Array){ return btoa(String.fromCharCode(...buf)) }
function base64ToBuf(b64: string){ return new Uint8Array(atob(b64).split('').map(c=>c.charCodeAt(0))) }

export default function Chat(){
  // Lock (WebAuthn-lite gate)
  const [unlocked,setUnlocked]=useState(false)
  useEffect(()=>{
    // lightweight 'gate': rely on localStorage flag; (for production back by server WebAuthn)
    const gate=localStorage.getItem('ahla_gate_ok')
    setUnlocked(gate==='1')
  },[])
  const handleUnlock=async ()=>{
    try{
      // Request platform authenticator (demo flow)
      if(!('credentials' in navigator)) throw new Error('No credentials API')
      // Fake challenge for demo only
      const challenge = new Uint8Array(16); crypto.getRandomValues(challenge)
      await navigator.credentials.get({ publicKey: { challenge, userVerification:'preferred', allowCredentials: [] } as any })
      localStorage.setItem('ahla_gate_ok','1'); setUnlocked(true)
    }catch(e){ alert('تعذّر الفتح بالبصمة/FaceID — مُنِح الدخول المحلي.'); localStorage.setItem('ahla_gate_ok','1'); setUnlocked(true) }
  }

  const [room,setRoom]=useState('personal')
  const [user,setUser]=useState('me')
  const [msgs,setMsgs]=useState<Msg[]>([])
  const [text,setText]=useState('')
  const [e2ee,setE2EE]=useState(true)
  const [theme,setTheme]=useState<'light'|'dark'>('light')
  const [search,setSearch]=useState('')

  const [rec, setRec] = useState<MediaRecorder|null>(null)
  const [recording, setRecording] = useState(false)

  const wsRef = useRef<WebSocket|null>(null)

  // E2EE keys (per device)
  const [pub,setPub]=useState<string>(''); const [priv,setPriv]=useState<string>('')

  useEffect(()=>{
    (async ()=>{
      let sk = await get('ahla_sk'); let pk = await get('ahla_pk')
      if(!sk || !pk){
        const kp = nacl.box.keyPair()
        sk = bufToBase64(kp.secretKey); pk = bufToBase64(kp.publicKey)
        await set('ahla_sk', sk); await set('ahla_pk', pk)
      }
      setPriv(sk); setPub(pk)
    })()
  },[])

  const shared = useMemo(()=>{
    if(!priv||!pub) return null
    const k = nacl.box.before(base64ToBuf(pub), base64ToBuf(priv))
    return k
  },[priv,pub])

  // Derive AES key from shared secret for file encryption
  const [aesKey,setAesKey]=useState<CryptoKey|null>(null)
  useEffect(()=>{
    (async ()=>{
      if(shared){
        const h = await sha256(shared)
        const key = await importAesKeyFromRaw(h)
        setAesKey(key)
      }
    })()
  },[shared])

  const decrypt = (m: Msg)=>{
    if(!m.cipher || !m.nonce || !shared) return m.text||''
    try{
      const pt = nacl.box.open.after(base64ToBuf(m.cipher), base64ToBuf(m.nonce), shared)
      if(!pt) return '[failed decrypt]'
      return new TextDecoder().decode(pt)
    }catch{ return '[failed decrypt]' }
  }

  const send = async ()=>{
    if(!text.trim()) return
    let payload: any = { id: crypto.randomUUID(), user, ts: Date.now() }
    if(e2ee && shared){
      const nonce = nacl.randomBytes(24)
      const ct = nacl.box.after(new TextEncoder().encode(text), nonce, shared)
      payload['cipher']=bufToBase64(ct); payload['nonce']=bufToBase64(nonce)
    } else {
      payload['text']=text
    }
    await fetch(`${API}/messages/${room}`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) })
    wsRef.current?.send(JSON.stringify({ type:'message', payload }))
    setText('')
  }

  const sendTyping = ()=>{
    wsRef.current?.send(JSON.stringify({ type:'typing', payload:{user, room, ts: Date.now()} }))
  }

  const onFile = async (e:any)=>{
    const f = e.target.files?.[0]; if(!f) return
    let fileToSend = f
    let ivB64: string|undefined = undefined
    if(aesKey && e2ee){
      const buf = new Uint8Array(await f.arrayBuffer())
      const { iv, ct } = await aesEncrypt(aesKey, buf.buffer)
      ivB64 = btoa(String.fromCharCode(...iv))
      fileToSend = new File([ct], f.name + ".enc", { type: "application/octet-stream" })
    }
    const form = new FormData(); form.append('file', fileToSend)
    const r = await fetch(`${API}/attachments/${room}`, { method:'POST', body: form })
    const j = await r.json()
    const payload = { id: crypto.randomUUID(), user, ts: Date.now(), attachments:[{name:f.name,url:j.url, iv: ivB64}] }
    await fetch(`${API}/messages/${room}`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) })
    wsRef.current?.send(JSON.stringify({ type:'message', payload }))
  }

  const downloadAndDecrypt = async (a:{name:string,url:string,iv?:string})=>{
    const res = await fetch(a.url)
    const blob = await res.blob()
    if(!a.iv || !aesKey || !e2ee){
      // open raw
      const u = URL.createObjectURL(blob)
      window.open(u, '_blank')
      return
    }
    const buf = new Uint8Array(await blob.arrayBuffer())
    const iv = new Uint8Array(atob(a.iv).split('').map(c=>c.charCodeAt(0)))
    const pt = await aesDecrypt(aesKey, iv, buf)
    const u = URL.createObjectURL(new Blob([pt], { type: 'application/octet-stream' }))
    const link = document.createElement('a'); link.href=u; link.download=a.name; link.click()
  }

  // Audio record
  const startRec = async ()=>{
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
    const r = new MediaRecorder(stream)
    const chunks: Blob[] = []
    r.ondataavailable = e=> chunks.push(e.data)
    r.onstop = async ()=>{
      const blob = new Blob(chunks, { type: 'audio/webm' })
      const file = new File([blob], `voice_${Date.now()}.webm`, { type:'audio/webm' })
      const event = { target:{ files:[file] } } as any
      await onFile(event)
    }
    r.start(); setRec(r); setRecording(true)
  }
  const stopRec = ()=> { rec?.stop(); setRecording(false) }

  // Push register
  const [pushOK, setPushOK] = useState(false)
  useEffect(()=>{
    (async ()=>{
      try{
        if(!('serviceWorker' in navigator)) return
        const reg = await navigator.serviceWorker.register('/chat/sw.js')
        await navigator.serviceWorker.ready
        if(Notification.permission!=='granted'){
          await Notification.requestPermission()
        }
        const vapidRes = await fetch(`${API}/push/vapidPublicKey`); const { key } = await vapidRes.json()
        if(!key) return
        const sub = await reg.pushManager.subscribe({ userVisibleOnly:true, applicationServerKey: urlB64ToUint8Array(key) })
        await fetch(`${API}/push/subscribe`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ user, sub }) })
        setPushOK(true)
      }catch(e){ console.log('push disabled', e) }
    })()
  },[user])

  function urlB64ToUint8Array(base64String:string) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4);
    const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/');
    const rawData = window.atob(base64);
    const outputArray = new Uint8Array(rawData.length);
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i);
    }
    return outputArray;
  }

  // Load & WS
  useEffect(()=>{
    fetch(`${API}/messages/${room}`).then(r=>r.json()).then(setMsgs).catch(()=>{})
    const ws = new WebSocket(`${WS_URL}`)
    wsRef.current = ws
    ws.onmessage = (ev)=>{
      try{
        const m = JSON.parse(ev.data)
        if(m.type==='message'){ setMsgs(prev=>[...prev, m.payload]) }
      }catch{}
    }
    return ()=> ws.close()
  },[room])

  const filtered = msgs.filter(m=>{
    if(!search.trim()) return true
    const body = m.attachments?.length? m.attachments.map(a=>a.name).join(' ') : (m.text ?? decrypt(m))
    return (body||'').toLowerCase().includes(search.toLowerCase())
  })

  if(!unlocked){
    return (<main style={{fontFamily:'system-ui',padding:24,display:'grid',placeItems:'center',minHeight:'100vh'}}>
      <div style={{border:'1px solid #ddd',padding:24,borderRadius:12,maxWidth:420,textAlign:'center'}}>
        <h1>قفل Ahla Chat</h1>
        <p>إفتح ببصمة الجهاز/Face ID (WebAuthn). إذا ما اشتغلت، بنسمح دخول محلي.</p>
        <button onClick={handleUnlock} style={{padding:'12px 18px',borderRadius:12,border:'1px solid #333'}}>فتح</button>
      </div>
    </main>)
  }

  return (
    <main data-theme={theme} style={{fontFamily:'system-ui',padding:16,maxWidth:720,margin:'0 auto'}}>
      <header style={{display:'flex',gap:8,alignItems:'center',marginBottom:8}}>
        <h1 style={{margin:0}}>Ahla Chat — Personal</h1>
        <span style={{fontSize:12,opacity:0.7}}>Push: {pushOK? 'ON':'OFF'}</span>
        <div style={{marginInlineStart:'auto',display:'flex',gap:8}}>
          <select value={theme} onChange={e=>setTheme(e.target.value as any)}>
            <option value="light">فاتح</option>
            <option value="dark">داكن</option>
          </select>
          <button onClick={recording? stopRec : startRec}>{recording? 'إيقاف صوت' : 'صوت 🔴'}</button>
          <button onClick={exportBackup}>تصدير نسخة احتياطية</button>
        </div>
      </header>

      <div style={{display:'flex',gap:8,alignItems:'center',marginBottom:8}}>
        <input value={user} onChange={e=>setUser(e.target.value)} placeholder="اسمك" style={{padding:8}}/>
        <input value={room} onChange={e=>setRoom(e.target.value)} placeholder="الغرفة" style={{padding:8}}/>
        <label style={{display:'flex',alignItems:'center',gap:6}}>
          <input type="checkbox" checked={e2ee} onChange={e=>setE2EE(e.target.checked)} /> E2EE
        </label>
        <input value={search} onChange={e=>setSearch(e.target.value)} placeholder="بحث محلي…" style={{padding:8,flex:1}}/>
      </div>

      <div style={{border:'1px solid #ddd',borderRadius:12,padding:12,height:420,overflow:'auto',background:'#fafafa'}}>
        {filtered.map(m=>{
          const mine = m.user===user
          const body = m.attachments?.length? `[📎 ${m.attachments.map(a=>a.name).join(', ')}]` : (m.text ?? decrypt(m))
          return (
            <div key={m.id} style={{display:'flex',justifyContent: mine?'flex-end':'flex-start', marginBottom:8}}>
              <div style={{background: mine?'#DCF8C6':'white', border:'1px solid #eee', borderRadius:12, padding:'8px 12px', maxWidth: '75%'}}>
                <div style={{fontSize:12,opacity:0.6}}>{m.user}</div>
                <div style={{whiteSpace:'pre-wrap'}}>{body}</div>
                {m.attachments?.map(a=>(
                  <div key={a.url}><a href="#" onClick={(e)=>{e.preventDefault(); downloadAndDecrypt(a)}}>{a.name}</a></div>
                ))}
                <div style={{textAlign:'end',fontSize:11,opacity:0.5}}>{new Date(m.ts).toLocaleTimeString()}</div>
              </div>
            </div>
          )
        })}
      </div>

      <div style={{display:'flex',gap:8,marginTop:8}}>
        <input value={text} onChange={e=>{setText(e.target.value); sendTyping()}} onKeyDown={(e)=> e.key==='Enter' && send()} placeholder="اكتب رسالة…" style={{flex:1,padding:12,borderRadius:12,border:'1px solid #ddd'}}/>
        <button onClick={send} style={{padding:'12px 16px',borderRadius:12,border:'1px solid #0a0',background:'#0c0',color:'#fff'}}>إرسال</button>
        <label style={{padding:'12px 16px',borderRadius:12,border:'1px solid #555',background:'#fff',cursor:'pointer'}}>📎
          <input onChange={onFile} type="file" style={{display:'none'}}/>
        </label>
      </div>
      <p style={{fontSize:12,opacity:0.7,marginTop:6}}>
        التشفير الطرفي تجريبي. للمستوى الإنتاجي اعتمد <a href="https://signal.org/docs/specifications/doubleratchet/" target="_blank">Double Ratchet</a> مع تبادل مفاتيح X3DH.
      </p>
    </main>
  )

  async function exportBackup(){
    const dump = JSON.stringify({ room, msgs }, null, 2)
    const blob = new Blob([dump], { type:'application/json' })
    const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = `ahla_backup_${Date.now()}.json`; a.click()
  }
}