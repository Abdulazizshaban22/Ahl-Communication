'use client'
import {useState} from 'react'
export default function Settings(){
  const [form,setForm]=useState({email:'',password:''})
  const [msg,setMsg]=useState<string|undefined>()
  async function signup(){
    const res = await fetch('/api/provision/signup',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(form)})
    const js = await res.json(); setMsg(js.ok?'تم إنشاء الحساب 🎉':'فشل: '+js.error)
  }
  return <div><h3>إعدادات</h3>
    <h4>تسجيل حساب بريد جديد (@ahla.com)</h4>
    <input placeholder="user@ahla.com" value={form.email} onChange={e=>setForm({...form,email:e.target.value})}/>
    <input placeholder="كلمة المرور" type="password" value={form.password} onChange={e=>setForm({...form,password:e.target.value})}/>
    <button onClick={signup}>تسجيل</button>
    {msg && <p>{msg}</p>}
  </div>
}
