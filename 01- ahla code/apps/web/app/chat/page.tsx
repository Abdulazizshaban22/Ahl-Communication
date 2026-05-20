'use client'
import React, { useState } from 'react'
import { SmartNudge } from '../components/SmartNudge'

type Msg = { id:string, author:'me'|'other', text:string }
const uid = ()=> Math.random().toString(36).slice(2)

export default function Chat(){
  const [context,setContext] = useState<'personal'|'family'|'work'>('personal')
  const [msgs,setMsgs] = useState<Msg[]>([
    {id:uid(), author:'other', text:'هلا! كيف يومك؟'}
  ])
  const [input,setInput] = useState('')
  const [suggestions,setSuggestions] = useState<string[]>([])

  async function send(){
    if(!input.trim()) return
    const m = {id:uid(), author:'me' as const, text: input.trim()}
    setMsgs([...msgs,m]); setInput('')
    // call ingest route (server will call engine or accept on-device results later)
    const res = await fetch('/api/emotion/ingest', {
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({
        chat_id:'demo-chat', message_id:m.id, author_id:'me',
        text:m.text, context })
    })
    const data = await res.json()
    setSuggestions(data.analysis?.suggestions ?? [])
  }

  return <div>
    <div style={{display:'flex', gap:10, marginBottom:10}}>
      <label>السياق:</label>
      <select value={context} onChange={e=>setContext(e.target.value as any)}>
        <option value="personal">شخصي</option>
        <option value="family">عائلي</option>
        <option value="work">عمل</option>
      </select>
    </div>

    <div style={{border:'1px solid #eee', borderRadius:12, padding:12, height:360, overflowY:'auto', marginBottom:12}}>
      {msgs.map(m=> <div key={m.id} style={{textAlign: m.author==='me'?'right':'left', margin:'6px 0'}}>
        <div style={{display:'inline-block', padding:'8px 12px', borderRadius:12, background: m.author==='me'?'#d1f7c4':'#eaeaea'}}>
          <b>{m.author==='me'?'أنا':'طرف آخر'}:</b> {m.text}
        </div>
      </div>)}
    </div>

    <div style={{display:'flex', gap:8}}>
      <input value={input} onChange={e=>setInput(e.target.value)} placeholder="اكتب رسالتك…" style={{flex:1, padding:12, border:'1px solid #ddd', borderRadius:10}}/>
      <button onClick={send} style={{padding:'12px 16px', borderRadius:10, border:'1px solid #0c0', background:'#0f0'}}>إرسال</button>
    </div>

    <SmartNudge suggestions={suggestions} onAccept={(s)=>alert('تنفيذ الاقتراح: '+s)} />
  </div>
}