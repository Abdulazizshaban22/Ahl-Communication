'use client'
import { useEffect, useState } from 'react'
const API = (typeof window!=='undefined' ? (window.location.origin + '/api/chat') : '')

export default function Settings(){
  const [room,setRoom]=useState('personal')
  const [ttl,setTtl]=useState(0)
  const [saved,setSaved]=useState(false)

  useEffect(()=>{
    fetch(`${API}/ttl/${room}`).then(r=>r.json()).then(j=> setTtl(j.ttl || 0)).catch(()=>{})
  },[room])

  const save = async ()=>{
    await fetch(`${API}/ttl/${room}`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ ttl }) })
    setSaved(true); setTimeout(()=>setSaved(false), 1200)
  }

  return (<main style={{fontFamily:'system-ui',padding:24}}>
    <h1>إعدادات المحادثة</h1>
    <div style={{display:'flex',gap:8,alignItems:'center'}}>
      <label>الغرفة</label>
      <input value={room} onChange={e=>setRoom(e.target.value)} />
      <label>الاختفاء بعد (ثوانٍ)</label>
      <input type="number" value={ttl} onChange={e=>setTtl(parseInt(e.target.value||'0'))} />
      <button onClick={save}>حفظ</button>
      {saved && <span>✔ تم</span>}
    </div>
    <p style={{opacity:0.7}}>إذا فعّلت الاختفاء، الرسائل الأقدم من القيمة سيتم إخفاؤها تلقائيًا عند الجلب.</p>
  </main>)
}