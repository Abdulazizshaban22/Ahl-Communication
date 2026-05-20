'use client'
import {useEffect,useState} from 'react'
export default function Inbox(){
  const [items,setItems]=useState<any[]>([])
  const [login,setLogin]=useState({u:'',p:''})
  const [stage,setStage]=useState<'auth'|'loading'|'ok'>('auth')
  async function load(){
    setStage('loading')
    // store in cookie for API routes (demo)
    await fetch('/api/session-mail-cred',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({username:login.u,password:login.p})})
    const res = await fetch('/api/jmap/list')
    const js = await res.json()
    setItems(js.items||[]); setStage('ok')
  }
  if(stage==='auth') return <div><h3>اربط حساب بريدك</h3><p>أدخل بريد @ahla.com وكلمة المرور (مؤقتًا، لأغراض التطوير).</p>
    <input placeholder="user@ahla.com" value={login.u} onChange={e=>setLogin({...login,u:e.target.value})}/>
    <input placeholder="password" type="password" value={login.p} onChange={e=>setLogin({...login,p:e.target.value})}/>
    <button onClick={load}>متابعة</button></div>
  if(stage==='loading') return <p>جاري تحميل البريد…</p>
  return <div><h3>📥 الوارد</h3>
    {items.length===0 && <p>لا توجد رسائل بعد.</p>}
    <ul>{items.map(it=><li key={it.id}><b>{it.from||'(بدون عنوان)'}</b> — {it.subject||'(بدون موضوع)'} <small>{it.receivedAt}</small></li>)}</ul>
  </div>
}
