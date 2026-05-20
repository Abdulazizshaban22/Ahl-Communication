'use client'
import { useEffect, useMemo, useRef, useState } from 'react'
import * as nacl from 'tweetnacl'
import { set, get } from 'idb-keyval'
import { pbkdf2Key, aesGcmEncrypt, aesGcmDecrypt, bufToB64, b64ToBuf } from '../lib/crypto'

type Msg = { id:string; user:string; text?:string; ts:number; attachments?:{name:string,url:string}[]; cipher?:string; nonce?:string; }
const WS_URL = (typeof window!=='undefined' ? (window.location.origin.replace(/^http/,'ws') + '/ws') : '')
const API = (typeof window!=='undefined' ? (window.location.origin + '/api/chat') : '')

function bufToBase64(buf: Uint8Array){ return btoa(String.fromCharCode(...buf)) }
function base64ToBuf(b64: string){ return new Uint8Array(atob(b64).split('').map(c=>c.charCodeAt(0))) }

export default function Chat(){
  const qs = typeof window!=='undefined' ? new URLSearchParams(window.location.search) : new URLSearchParams()
  const initRoom = qs.get('room') || 'personal'

  const [room,setRoom]=useState(initRoom)
  const [user,setUser]=useState('me')
  const [msgs,setMsgs]=useState<Msg[]>([])
  const [text,setText]=useState('')
  const [e2ee,setE2EE]=useState(true)
  const [pushOK,setPushOK]=useState(false)
  const wsRef = useRef<WebSocket|null>(null)

  // listen from SW for open-room
  useEffect(()=>{
    navigator.serviceWorker?.addEventListener('message', (ev:any)=>{
      if(ev.data?.type==='open-room' && ev.data.room){ setRoom(ev.data.room) }
    })
  },[])

  // Keys
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
    return nacl.box.before(base64ToBuf(pub), base64ToBuf(priv))
  },[priv,pub])

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

  const onFile = async (e:any)=>{
    const f = e.target.files?.[0]; if(!f) return
    const form = new FormData(); form.append('file', f)
    const r = await fetch(`${API}/attachments/${room}`, { method:'POST', body: form })
    const j = await r.json()
    const payload = { id: crypto.randomUUID(), user, ts: Date.now(), attachments:[{name:f.name,url:j.url}] }
    await fetch(`${API}/messages/${room}`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) })
    wsRef.current?.send(JSON.stringify({ type:'message', payload }))
  }

  // load + ws
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

  // Push subscribe (A)
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
        const appServerKey = urlB64ToUint8Array(key)
        const sub = await reg.pushManager.subscribe({ userVisibleOnly:true, applicationServerKey: appServerKey })
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

  // Backup (D: encrypted export/import)
  async function exportBackup(){
    const dump = JSON.stringify({ room, msgs }, null, 2)
    const pass = prompt('أدخل كلمة مرور للنسخة الاحتياطية:') || ''
    const salt = crypto.getRandomValues(new Uint8Array(16))
    const key  = await pbkdf2Key(pass, salt)
    const { iv, ct } = await aesGcmEncrypt(key, new TextEncoder().encode(dump))
    const pack = { salt: bufToB64(salt), iv: bufToB64(iv), data: bufToB64(ct) }
    const blob = new Blob([JSON.stringify(pack)], { type:'application/json' })
    const a = document.createElement('a'); a.href = URL.createObjectURL(blob); a.download = `ahla_backup_enc_${Date.now()}.json`; a.click()
  }
  async function importBackup(e:any){
    const file = e.target.files?.[0]; if(!file) return
    const text = await file.text()
    const pack = JSON.parse(text)
    const pass = prompt('أدخل كلمة مرور النسخة الاحتياطية:') || ''
    const key  = await pbkdf2Key(pass, b64ToBuf(pack.salt))
    const pt   = await aesGcmDecrypt(key, b64ToBuf(pack.iv), b64ToBuf(pack.data))
    const j = JSON.parse(new TextDecoder().decode(pt))
    if(Array.isArray(j.msgs)) setMsgs(j.msgs)
    alert('تم الاستيراد.')
  }

  return (
    <main style={{fontFamily:'system-ui',padding:16,maxWidth:720,margin:'0 auto'}}>
      <header style={{display:'flex',gap:8,alignItems:'center',marginBottom:8}}>
        <h1 style={{margin:0}}>Ahla Chat — v3.1</h1>
        <span style={{fontSize:12,opacity:0.7}}>Push: {pushOK? 'ON':'OFF'}</span>
        <div style={{marginInlineStart:'auto',display:'flex',gap:8}}>
          <button onClick={exportBackup}>تصدير نسخة مشفّرة</button>
          <label style={{border:'1px solid #ccc',padding:'6px 8px',borderRadius:8,cursor:'pointer'}}>استيراد
            <input type="file" accept="application/json" style={{display:'none'}} onChange={importBackup}/>
          </label>
        </div>
      </header>

      <div style={{display:'flex',gap:8,alignItems:'center',marginBottom:8}}>
        <input value={user} onChange={e=>setUser(e.target.value)} placeholder="اسمك" style={{padding:8}}/>
        <input value={room} onChange={e=>setRoom(e.target.value)} placeholder="الغرفة" style={{padding:8}}/>
        <label style={{display:'flex',alignItems:'center',gap:6}}>
          <input type="checkbox" checked={e2ee} onChange={e=>setE2EE(e.target.checked)} /> E2EE
        </label>
      </div>

      <div style={{border:'1px solid #ddd',borderRadius:12,padding:12,height:420,overflow:'auto',background:'#fafafa'}}>
        {msgs.map(m=>{
          const mine = m.user===user
          const body = m.attachments?.length? `[📎 ${m.attachments.map(a=>a.name).join(', ')}]` : (m.text ?? decrypt(m))
        return (
          <div key={m.id} style={{display:'flex',justifyContent: mine?'flex-end':'flex-start', marginBottom:8}}>
            <div style={{background: mine?'#DCF8C6':'white', border:'1px solid #eee', borderRadius:12, padding:'8px 12px', maxWidth: '75%'}}>
              <div style={{fontSize:12,opacity:0.6}}>{m.user}</div>
              <div style={{whiteSpace:'pre-wrap'}}>{body}</div>
              {m.attachments?.map(a=>(
                <div key={a.url}><a href={a.url} target="_blank" rel="noreferrer">{a.name}</a></div>
              ))}
              <div style={{textAlign:'end',fontSize:11,opacity:0.5}}>{new Date(m.ts).toLocaleTimeString()}</div>
            </div>
          </div>
        )})}
      </div>

      <div style={{display:'flex',gap:8,marginTop:8}}>
        <input value={text} onChange={e=>setText(e.target.value)} onKeyDown={(e)=> e.key==='Enter' && send()} placeholder="اكتب رسالة…" style={{flex:1,padding:12,borderRadius:12,border:'1px solid #ddd'}}/>
        <button onClick={send} style={{padding:'12px 16px',borderRadius:12,border:'1px solid #0a0',background:'#0c0',color:'#fff'}}>إرسال</button>
        <label style={{padding:'12px 16px',borderRadius:12,border:'1px solid #555',background:'#fff',cursor:'pointer'}}>📎
          <input onChange={onFile} type="file" style={{display:'none'}}/>
        </label>
      </div>
    </main>
  )
}