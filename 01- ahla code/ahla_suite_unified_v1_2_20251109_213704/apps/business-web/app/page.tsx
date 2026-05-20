
'use client'
import { useEffect, useState } from 'react'
export default function Business(){
  const [tasks,setTasks]=useState<any[]>([]); const [t,setT]=useState('')
  const load=()=> fetch('/api/business/tasks').then(r=>r.json()).then(setTasks)
  useEffect(load,[])
  const add=async ()=>{ await fetch('/api/business/tasks',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({title:t})}); setT(''); load() }
  return <main style={{fontFamily:'system-ui',padding:16}}>
    <h1>Ahla Business</h1>
    <div style={{display:'flex',gap:8}}>
      <input value={t} onChange={e=>setT(e.target.value)} placeholder="مهمة جديدة…" style={{padding:8}}/>
      <button onClick={add}>إضافة</button>
    </div>
    <ul>{tasks.map((x:any)=> <li key={x.id}>{x.title}</li>)}</ul>
  </main>
}
