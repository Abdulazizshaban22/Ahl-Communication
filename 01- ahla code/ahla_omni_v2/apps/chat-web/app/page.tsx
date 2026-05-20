'use client'
import {useEffect,useRef,useState} from 'react'
import {connect, StringCodec, JSONCodec} from 'nats.ws'

export default function Page(){
  const [room,setRoom]=useState('general')
  const [user,setUser]=useState('user@ahla.com')
  const [text,setText]=useState('')
  const [msgs,setMsgs]=useState<string[]>([])
  const subRef = useRef<any>(null)
  const ncRef = useRef<any>(null)

  useEffect(()=>{
    (async ()=>{
      const url = process.env.NEXT_PUBLIC_NATS_WS || 'ws://localhost:9222'
      const nc = await connect({servers: url, name: 'ahla-chat-web'})
      ncRef.current = nc
      const sc = StringCodec(); const jc = JSONCodec()
      const subj = `chat.room.${room}`
      const sub = nc.subscribe(subj, {queue:'web'})
      subRef.current = sub
      ;(async ()=>{
        for await (const m of sub){
          try{
            const data = jc.decode(m.data) as any
            setMsgs((x)=>[`[${data.ts}] ${data.user}: ${data.text}`, ...x])
          }catch{
            setMsgs((x)=>[sc.decode(m.data), ...x])
          }
        }
      })()
    })()
    return ()=>{ try{ subRef.current?.drain(); ncRef.current?.drain() }catch{} }
  },[room])

  async function send(){
    await fetch(`${process.env.NEXT_PUBLIC_CHAT_API}/send`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({room,user,text})})
    setText('')
  }
  return <main style={{maxWidth:720,margin:'24px auto',padding:16}}>
    <h2>Ahla Chat — Live via NATS WS</h2>
    <div style={{display:'flex',gap:8}}>
      <input value={room} onChange={e=>setRoom(e.target.value)} placeholder="room"/>
      <input value={user} onChange={e=>setUser(e.target.value)} placeholder="you@ahla.com"/>
    </div>
    <div style={{marginTop:12}}>
      <input style={{width:'80%'}} value={text} onChange={e=>setText(e.target.value)} placeholder="message"/>
      <button onClick={send}>Send</button>
    </div>
    <ul>{msgs.map((m,i)=><li key={i}>{m}</li>)}</ul>
  </main>
}
