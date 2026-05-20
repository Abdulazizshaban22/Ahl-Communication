'use client'
import { useEffect, useMemo, useRef, useState } from 'react'
import * as nacl from 'tweetnacl'
import { set, get } from 'idb-keyval'

type Msg = { id:string; user:string; text?:string; ts:number; attachments?:{name:string,url:string}[]; cipher?:string; nonce?:string; }
const WS_URL = (typeof window!=='undefined' ? (window.location.origin.replace(/^http/,'ws') + '/ws') : '')
const API = (typeof window!=='undefined' ? (window.location.origin + '/api/chat') : '')

function bufToBase64(buf: Uint8Array){ return btoa(String.fromCharCode(...buf)) }
function base64ToBuf(b64: string){ return new Uint8Array(atob(b64).split('').map(c=>c.charCodeAt(0))) }

export default function Chat(){
  const [room,setRoom]=useState('personal')
  const [user,setUser]=useState('me')
  const [msgs,setMsgs]=useState<Msg[]>([])
  const [text,setText]=useState('')
  const [e2ee,setE2EE]=useState(true)
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

  // very simple shared secret per room stored locally (demo only)
  const shared = useMemo(()=>{
    if(!priv||!pub) return null
    // Self-DH just to produce a deterministic key — for demo we use our own pub; in real use exchange via QR/Invite.
    const k = nacl.box.before(base64ToBuf(pub), base64ToBuf(priv))
    return k
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

  const sendTyping = ()=>{
    wsRef.current?.send(JSON.stringify({ type:'typing', payload:{user, room, ts: Date.now()} }))
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

  return (
    <main style={{fontFamily:'system-ui',padding:16,maxWidth:680,margin:'0 auto'}}>
      <h1>Ahla Chat — Personal</h1>
      <div style={{display:'flex',gap:8,alignItems:'center',marginBottom:8}}>
        <input value={user} onChange={e=>setUser(e.target.value)} placeholder="اسمك" style={{padding:8}}/>
        <input value={room} onChange={e=>setRoom(e.target.value)} placeholder="الغرفة" style={{padding:8}}/>
        <label style={{display:'flex',alignItems:'center',gap:6}}>
          <input type="checkbox" checked={e2ee} onChange={e=>setE2EE(e.target.checked)} /> E2EE
        </label>
        <span style={{marginInlineStart:'auto',fontSize:12,opacity:0.7}}>Device key: {pub.slice(0,8)}…</span>
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
      <p style={{fontSize:12,opacity:0.7,marginTop:6}}>التشفير طرفي اختياري (تجريبي). الخادم يخزّن نصًا مُعمّى عندما يكون E2EE مفعّلًا.</p>
    </main>
  )
}