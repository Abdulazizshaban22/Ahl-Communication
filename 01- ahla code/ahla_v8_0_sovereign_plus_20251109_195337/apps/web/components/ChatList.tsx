'use client'
import { useEffect, useRef } from 'react'

type Msg = { id:string; user:string; text?:string; enc?:any; ts:number }

export default function ChatList({ messages, decrypt }:{ messages: Msg[], decrypt:(enc:any)=>Promise<string|undefined> }) {
  const ref = useRef<HTMLDivElement>(null)
  useEffect(()=>{ ref.current?.scrollTo({top:ref.current.scrollHeight, behavior:'smooth'}) }, [messages])
  return (
    <div ref={ref} className="flex-1 overflow-y-auto p-3 space-y-2">
      {messages.map((m, i) => (
        <Bubble key={m.id+':'+i} msg={m} decrypt={decrypt}/>
      ))}
    </div>
  )
}

function Bubble({ msg, decrypt }:{ msg:Msg, decrypt:(enc:any)=>Promise<string|undefined> }){
  const mine = msg.user==='أنا'
  const [text, setText] = (require('react') as any).useState<string | undefined>(msg.text)

  ;(async ()=>{
    if(!text && msg.enc){
      try { setText(await decrypt(msg.enc)) } catch {}
    }
  })()

  return (
    <div className={`max-w-[80%] ${mine?'ms-auto text-white bg-ahla-green':'bg-white/80'} px-3 py-2 rounded-2xl shadow`}>
      <div className="text-sm opacity-70">{msg.user}</div>
      <div className="leading-relaxed break-words">{text ?? '🔒 رسالة خاصة (E2EE)'}</div>
      <div className="text-[10px] opacity-60 mt-1">{new Date(msg.ts).toLocaleTimeString()}</div>
    </div>
  )
}
