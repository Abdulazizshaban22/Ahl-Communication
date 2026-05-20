
'use client'
import { useEffect, useRef, useState } from 'react'
import { ensureIdentity, seal, open } from '../lib/e2ee'

export default function Chat(){
  const [room,setRoom]=useState('personal'); const [peer,setPeer]=useState('')
  const [msgs,setMsgs]=useState<any[]>([]); const [t,setT]=useState('')
  const [pub,setPub]=useState(''); const priv=useRef<Uint8Array|null>(null)
  const ws=useRef<WebSocket|null>(null)
  useEffect(()=>{ ensureIdentity().then(k=>{ setPub(k.pub); priv.current=k.priv }) },[])
  useEffect(()=>{ 
    fetch('/api/chat/messages/'+room).then(r=>r.json()).then(setMsgs).catch(()=>{})
    const s=new WebSocket((location.origin.replace(/^http/,'ws'))+'/api/chat/ws?room='+room)
    s.onmessage=e=>{ try{ const m=JSON.parse(e.data); if(m.type==='message'){ 
      const p=m.payload; if(p.c){ const plain=open(priv.current!, p.c.eph, p.c.n, p.c.c); if(plain) p.text=plain }
      setMsgs(x=>[...x,p]) } }catch{} }
    ws.current=s; return ()=>s.close()
  },[room])
  const send=async ()=>{
    if(!t.trim())return
    let payload:any={ id:crypto.randomUUID(), user:'me', ts:Date.now(), text:t }
    if(peer){ payload={ id:payload.id, user:'me', ts:payload.ts, c:seal(peer,t) } }
    await fetch('/api/chat/messages/'+room,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(payload)})
    ws.current?.send(JSON.stringify({type:'message',payload})); setT('')
  }
  return <main style={{fontFamily:'system-ui',padding:16,maxWidth:780,margin:'0 auto'}}>
    <h1>Ahla Chat</h1>
    <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8}}>
      <input value={room} onChange={e=>setRoom(e.target.value)} placeholder="room" style={{padding:8}}/>
      <input value={peer} onChange={e=>setPeer(e.target.value)} placeholder="Peer Public Key (Base64)" style={{padding:8}}/>
    </div>
    <div style={{fontSize:12,opacity:.7,marginTop:6}}><b>My Public:</b> {pub||'…'}</div>
    <div style={{border:'1px solid #ddd',borderRadius:10,padding:10,height:360,overflow:'auto',marginTop:8}}>
      {msgs.map(m=><div key={m.id}><b>{m.user}</b>: {m.text || (m.c?'[encrypted]':'')} <i style={{opacity:.6}}>{new Date(m.ts).toLocaleTimeString()}</i></div>)}
    </div>
    <div style={{display:'flex',gap:8,marginTop:8}}>
      <input value={t} onChange={e=>setT(e.target.value)} onKeyDown={e=>e.key==='Enter'&&send()} placeholder="اكتب رسالة…" style={{flex:1,padding:10,border:'1px solid #ddd',borderRadius:10}}/>
      <button onClick={send} style={{padding:'10px 16px',borderRadius:10}}>إرسال</button>
    </div>
  </main>
}
