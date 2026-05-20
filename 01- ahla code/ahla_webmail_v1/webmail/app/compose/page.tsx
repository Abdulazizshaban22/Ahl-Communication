'use client'
import {useState} from 'react'
export default function Compose(){
  const [to,setTo]=useState('')
  const [subject,setSubject]=useState('')
  const [text,setText]=useState('')
  const [sent,setSent]=useState<string|undefined>()
  async function send(){
    const res = await fetch('/api/jmap/send',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({to,subject,text})})
    const js = await res.json(); setSent(js?.id||'ok')
  }
  return <div><h3>✉️ إنشاء رسالة</h3>
    <input placeholder="to@example.com" value={to} onChange={e=>setTo(e.target.value)} /><br/>
    <input placeholder="الموضوع" value={subject} onChange={e=>setSubject(e.target.value)} /><br/>
    <textarea placeholder="المحتوى" value={text} onChange={e=>setText(e.target.value)} rows={8} style={{width:'100%'}}/><br/>
    <button onClick={send}>إرسال</button>
    {sent && <p>تم الإرسال: {sent}</p>}
  </div>
}
