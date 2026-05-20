'use client'
import { useState } from 'react'

export default function MessageInput({ onSend }:{ onSend:(t:string)=>void }) {
  const [val,setVal] = useState('')
  return (
    <div className="p-3 flex gap-2">
      <input value={val} onChange={e=>setVal(e.target.value)} onKeyDown={e=>{ if(e.key==='Enter' && val.trim()){ onSend(val.trim()); setVal('') } }} className="flex-1 px-4 py-3 rounded-2xl bg-white outline-none shadow" placeholder="اكتب رسالة..."/>
      <button onClick={()=>{ if(val.trim()){ onSend(val.trim()); setVal('') }}} className="px-5 py-3 rounded-2xl bg-ahla-green text-white">إرسال</button>
    </div>
  )
}
