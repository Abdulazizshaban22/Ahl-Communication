'use client'
import {useEffect,useState} from 'react'
export default function Page(){
  const [room,setRoom]=useState('general')
  const [user,setUser]=useState('user@ahla.com')
  const [text,setText]=useState('')
  const [msgs,setMsgs]=useState<string[]>([])

  useEffect(()=>{
    const ws = new WebSocket(process.env.NEXT_PUBLIC_NATS_WS!.replace('ws://','ws://')+'/'); // NATS WS is used by clients with protocol, here we simply demo WebSocket echo via chat-api
    ws.close(); // placeholder; actual UI consumes from HTTP polling for demo
  },[])

  async function send(){
    await fetch(process.env.NEXT_PUBLIC_CHAT_API!+'/send',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({room,user,text})})
    setMsgs(x=>[`${user}: ${text}`,...x]); setText('')
  }
  return <main style={{maxWidth:720,margin:'24px auto',padding:16}}>
    <h2>Ahla Chat</h2>
    <input value={room} onChange={e=>setRoom(e.target.value)} placeholder="room"/> &nbsp;
    <input value={user} onChange={e=>setUser(e.target.value)} placeholder="you@ahla.com"/>
    <div style={{marginTop:12}}><input value={text} onChange={e=>setText(e.target.value)} placeholder="message"/><button onClick={send}>إرسال</button></div>
    <ul>{msgs.map((m,i)=><li key={i}>{m}</li>)}</ul>
  </main>
}
