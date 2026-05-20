'use client'
import React,{useState} from 'react'
export default function Page(){
 const [msgs,setMsgs]=useState<{a:'me'|'peer',t:string}[]>([{a:'peer',t:'هلا!'}])
 const [text,setText]=useState('')
 async function send(){ if(!text.trim())return; const t=text.trim(); setText(''); setMsgs([...msgs,{a:'me',t}]); try{ await fetch((process as any).env.NEXT_PUBLIC_CHAT_API||'http://localhost:8082/api/messages',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({chat_id:'demo',text:t})}) }catch{} }
 return <div><div style={{border:'1px solid #eee',borderRadius:12,padding:12,height:360,overflow:'auto'}}>{msgs.map((m,i)=><div key={i} style={{textAlign:m.a==='me'?'right':'left',margin:'6px 0'}}><span style={{background:m.a==='me'?'#d1f7c4':'#eee',padding:'8px 12px',borderRadius:12}}>{m.t}</span></div>)}</div><div style={{display:'flex',gap:8,marginTop:8}}><input value={text} onChange={e=>setText(e.target.value)} placeholder="اكتب رسالة…" style={{flex:1,padding:12,border:'1px solid #ddd',borderRadius:10}}/><button onClick={send}>إرسال</button></div></div>
}