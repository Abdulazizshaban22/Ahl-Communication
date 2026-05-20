
'use client'
import { useEffect, useRef, useState } from 'react'
import { ensureIdentity, seal, open, safetyNumber } from '../lib/e2ee'
import * as idb from 'idb-keyval'

export default function Chat(){
  const [room,setRoom]=useState('personal')
  const [text,setText]=useState('')
  const [msgs,setMsgs]=useState<any[]>([])
  const [peerPub,setPeerPub]=useState('')
  const [myPub,setMyPub]=useState('')
  const privRef = useRef<Uint8Array|null>(null)
  const wsRef = useRef<WebSocket|null>(null)

  useEffect(()=>{
    ensureIdentity().then(k=>{
      privRef.current = k.idPriv
      setMyPub(k.idPub)
    })
  },[])

  useEffect(()=>{
    fetch('/api/chat/messages/'+room).then(r=>r.json()).then(setMsgs).catch(()=>{})
    const ws = new WebSocket((location.origin.replace(/^http/,'ws'))+'/ws?room='+room)
    ws.onmessage = ev=>{
      try{
        const m = JSON.parse(ev.data)
        if(m.type==='message'){
          const payload = m.payload
          if(payload.cipher){
            const plain = open(privRef.current!, payload.cipher.ephPub, payload.cipher.nonce, payload.cipher.ct)
            if(plain){ payload.text = plain }
          }
          setMsgs(prev=>[...prev, payload])
        }
      }catch{}
    }
    wsRef.current = ws
    return ()=> ws.close()
  },[room])

  const send=async ()=>{
    if(!text.trim()) return
    let payload:any={ id:crypto.randomUUID(), user:'me', ts:Date.now(), text }
    if(peerPub){
      const cipher = seal(peerPub, text)
      payload = { id:payload.id, user:'me', ts:payload.ts, cipher }
    }
    await fetch('/api/chat/messages/'+room,{ method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(payload)})
    wsRef.current?.send(JSON.stringify({type:'message',payload}))
    setText('')
  }

  const exportKeys=async ()=>{
    const keys = await idb.get('e2ee:keypair')
    const blob = new Blob([JSON.stringify(keys)],{type:'application/json'})
    const a = document.createElement('a')
    a.href = URL.createObjectURL(blob); a.download='ahla-e2ee-backup.json'; a.click()
  }

  const [finger,setFinger]=useState('')
  useEffect(()=>{
    if(peerPub && myPub){
      safetyNumber(peerPub, myPub).then(setFinger)
    } else setFinger('')
  },[peerPub,myPub])

  return <main style={{fontFamily:'system-ui',padding:16,maxWidth:760,margin:'0 auto'}}>
    <h1>Ahla Chat — E2EE</h1>
    <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8,marginBottom:10}}>
      <div><label>Room</label><input value={room} onChange={e=>setRoom(e.target.value)} style={{width:'100%',padding:8}}/></div>
      <div><label>Peer Public Key (Base64)</label><input value={peerPub} onChange={e=>setPeerPub(e.target.value)} style={{width:'100%',padding:8}}/></div>
    </div>
    <div style={{marginBottom:8,fontSize:13,opacity:.8}}>
      <b>My Public Key:</b> {myPub || '(generating...)'}<br/>
      <b>Safety Number:</b> {finger || '—'} <button onClick={exportKeys} style={{marginLeft:8}}>Export Backup</button>
    </div>
    <div style={{border:'1px solid #ddd',borderRadius:12,padding:12,height:360,overflow:'auto',background:'#fafafa'}}>
      {msgs.map(m=><div key={m.id} style={{margin:'6px 0'}}><b>{m.user}</b>: {m.text || (m.cipher?'[encrypted]':'')} <i style={{opacity:.6}}>{new Date(m.ts).toLocaleTimeString()}</i></div>)}
    </div>
    <div style={{display:'flex',gap:8,marginTop:8}}>
      <input placeholder="اكتب رسالة…" value={text} onChange={e=>setText(e.target.value)} onKeyDown={e=>e.key==='Enter'&&send()} style={{flex:1,padding:10,border:'1px solid #ddd',borderRadius:10}}/>
      <button onClick={send} style={{padding:'10px 16px',borderRadius:10}}>إرسال</button>
    </div>
    <p style={{fontSize:12,opacity:.7,marginTop:8}}>ملاحظة: عند إدخال مفتاح الطرف الآخر (Base64)، تُفعّل التشفير طرف-لطرف. يستمر التخزين مشفّرًا؛ الخادم لا يرى النص.</p>
  </main>
}
