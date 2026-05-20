
'use client'
import { useEffect, useState } from 'react'
export default function Mail(){
  const [list,setList]=useState<any[]>([]); const [to,setTo]=useState(''); const [subject,setSubject]=useState(''); const [body,setBody]=useState('')
  const load=()=> fetch('/api/mail/messages?mailbox=INBOX&limit=50').then(r=>r.json()).then(setList)
  useEffect(load,[])
  const send=async ()=>{ await fetch('/api/mail/send',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({to,subject,text:body})}); setTo(''); setSubject(''); setBody('') }
  return <main style={{fontFamily:'system-ui',padding:16}}>
    <h1>Ahla Mail</h1>
    <button onClick={load}>تحديث</button>
    <ul>{list.map((m:any)=><li key={m.id}><b>{m.subject||'(بدون عنوان)'}</b> — {m.from}</li>)}</ul>
    <h3>إرسال</h3>
    <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8}}>
      <input placeholder="to@example.com" value={to} onChange={e=>setTo(e.target.value)} style={{padding:8}}/>
      <input placeholder="الموضوع" value={subject} onChange={e=>setSubject(e.target.value)} style={{padding:8}}/>
    </div>
    <textarea placeholder="نص الرسالة" value={body} onChange={e=>setBody(e.target.value)} style={{width:'100%',height:120,marginTop:8}}/>
    <div><button onClick={send} style={{marginTop:8}}>إرسال</button></div>
  </main>
}
