
'use client'
import { useEffect, useState, useRef } from 'react'

export default function Home(){
  const [room,setRoom]=useState('personal')
  const [text,setText]=useState('')
  const [msgs,setMsgs]=useState<any[]>([])
  const wsRef = useRef<WebSocket|null>(null)

  useEffect(()=>{
    fetch('/api/chat/messages/'+room).then(r=>r.json()).then(setMsgs).catch(()=>{})
    const ws = new WebSocket((location.origin.replace(/^http/,'ws'))+'/ws?room='+room)
    ws.onmessage = ev=>{
      try{ const m = JSON.parse(ev.data); if(m.type==='message') setMsgs(prev=>[...prev,m.payload]) }catch{}
    }
    wsRef.current = ws
    return ()=> ws.close()
  },[room])

  const send=async ()=>{
    if(!text.trim()) return
    const payload={ id:crypto.randomUUID(), user:'me', ts:Date.now(), text }
    await fetch('/api/chat/messages/'+room,{ method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(payload)})
    wsRef.current?.send(JSON.stringify({type:'message',payload}))
    setText('')
  }

  return <main style={{fontFamily:'system-ui',padding:16,maxWidth:720,margin:'0 auto'}}>
    <h1>Ahla Chat</h1>
    <div style={{display:'flex',gap:8,marginBottom:8}}>
      <input value={room} onChange={e=>setRoom(e.target.value)} style={{padding:8}}/>
      <button onClick={()=>location.href='/chat/'}>تحديث</button>
    </div>
    <div style={{border:'1px solid #ddd',borderRadius:12,padding:12,height:380,overflow:'auto',background:'#fafafa'}}>
      {msgs.map(m=><div key={m.id} style={{margin:'6px 0'}}><b>{m.user}</b>: {m.text||'[msg]'} <i style={{opacity:.6}}>{new Date(m.ts).toLocaleTimeString()}</i></div>)}
    </div>
    <div style={{display:'flex',gap:8,marginTop:8}}>
      <input placeholder="اكتب رسالة…" value={text} onChange={e=>setText(e.target.value)} onKeyDown={e=>e.key==='Enter'&&send()} style={{flex:1,padding:10,border:'1px solid #ddd',borderRadius:10}}/>
      <button onClick={send} style={{padding:'10px 16px',borderRadius:10}}>إرسال</button>
    </div>
  </main>
}
