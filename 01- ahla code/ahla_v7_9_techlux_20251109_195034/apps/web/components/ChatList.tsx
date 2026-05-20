'use client'
import { useEffect, useRef } from 'react'

type Msg = { id:string; user:string; text:string; ts:number }

export default function ChatList({ messages }: { messages: Msg[] }) {
  const ref = useRef<HTMLDivElement>(null)
  useEffect(()=>{ ref.current?.scrollTo({top:ref.current.scrollHeight, behavior:'smooth'}) }, [messages])
  return (
    <div ref={ref} className="flex-1 overflow-y-auto p-3 space-y-2">
      {messages.map(m => (
        <div key={m.id} className={`max-w-[80%] ${m.user==='أنا'?'ms-auto text-white bg-ahla-green':'bg-white/80'} px-3 py-2 rounded-2xl shadow`}>
          <div className="text-sm opacity-70">{m.user}</div>
          <div className="leading-relaxed">{m.text}</div>
          <div className="text-[10px] opacity-60 mt-1">{new Date(m.ts).toLocaleTimeString()}</div>
        </div>
      ))}
    </div>
  )
}
