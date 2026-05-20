'use client'
import { useEffect, useMemo, useState } from 'react'
import ChatList from '@/components/ChatList'
import MessageInput from '@/components/MessageInput'

type Msg = { id:string; user:string; text:string; ts:number }

function uid(){ return Math.random().toString(36).slice(2) }

export default function ChatPage(){
  const [messages, setMessages] = useState<Msg[]>([])
  const [ws, setWs] = useState<WebSocket | null>(null)
  const username = 'أنا'
  const room = 'general'
  const wsUrl = process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8080/ws'
  const apiBase = process.env.NEXT_PUBLIC_API_BASE || 'http://localhost:8000'

  useEffect(()=>{
    const sock = new WebSocket(`${wsUrl}?room=${room}&user=${encodeURIComponent(username)}`)
    sock.onopen = ()=>{ /* ready */ }
    sock.onmessage = (ev)=>{
      try{
        const data = JSON.parse(ev.data)
        if(data.type==='message'){
          setMessages(m=>[...m, data.payload])
        }else if(data.type==='init'){
          // fetch history
          fetch(`${apiBase}/messages/${room}`).then(r=>r.json()).then(h=> setMessages(h || []))
        }
      }catch{}
    }
    sock.onclose = ()=>{ /* retry? */ }
    setWs(sock)
    return ()=> sock.close()
  },[])

  async function onSend(text:string){
    const payload:Msg = { id: uid(), user: username, text, ts: Date.now() }
    ws?.send(JSON.stringify({ type:'message', payload, room }))
    setMessages(m=>[...m, payload])
    try{
      // get smart replies suggestion (silent)
      const s = await fetch(`${apiBase}/suggest`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ text })})
      const j = await s.json()
      if(Array.isArray(j?.suggestions) && j.suggestions.length){
        console.debug('Smart suggestions:', j.suggestions)
      }
    }catch{}
  }

  return (
    <div className="min-h-screen grid grid-rows-[auto,1fr,auto] bg-[url('data:image/svg+xml,<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 10 10\'><circle cx=\'1\' cy=\'1\' r=\'.5\' fill=\'%23dcdcdc\' opacity=\'0.3\'/></svg>')]">
      <header className="h-14 flex items-center justify-between px-4 bg-white/70 backdrop-blur-md shadow-glass">
        <div className="font-semibold text-ahla-green">أهلا — محادثة</div>
        <div className="text-xs text-gray-600">غرفة: {room}</div>
      </header>
      <ChatList messages={messages}/>
      <MessageInput onSend={onSend}/>
    </div>
  )
}
