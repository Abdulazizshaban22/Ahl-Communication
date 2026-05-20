
'use client'
import { useEffect, useState } from 'react'
export default function Biz(){
  const [tasks,setTasks]=useState<any[]>([])
  const [title,setTitle]=useState('')
  const refresh=()=> fetch('/api/business/tasks').then(r=>r.json()).then(setTasks)
  useEffect(()=>{ refresh() },[])
  const add=async ()=>{ await fetch('/api/business/tasks',{ method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify({title})}); setTitle(''); refresh() }
  return <main style={{fontFamily:'system-ui',padding:16}}>
    <h1>Ahla Business</h1>
    <div style={{display:'flex',gap:8}}>
      <input value={title} onChange={e=>setTitle(e.target.value)} placeholder="مهمة جديدة" style={{padding:8}}/>
      <button onClick={add}>إضافة</button>
    </div>
    <ul>{tasks.map(t=><li key={t.id}>{t.title} — <small>{t.status}</small></li>)}</ul>
  </main>
}
