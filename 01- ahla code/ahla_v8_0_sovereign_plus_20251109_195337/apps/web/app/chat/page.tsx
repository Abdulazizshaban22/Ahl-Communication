'use client'
import { useEffect, useMemo, useState } from 'react'
import ChatList from '@/components/ChatList'
import MessageInput from '@/components/MessageInput'

type Msg = { id:string; user:string; text?:string; enc?:any; ts:number }

function uid(){ return Math.random().toString(36).slice(2) }

async function genKey(){
  const k = await crypto.subtle.generateKey({ name:'AES-GCM', length:256 }, true, ['encrypt','decrypt'])
  const raw = await crypto.subtle.exportKey('raw', k)
  return { key:k, b64: btoa(String.fromCharCode(...new Uint8Array(raw))) }
}
async function importKey(b64:string){
  const raw = Uint8Array.from(atob(b64), c=>c.charCodeAt(0))
  return crypto.subtle.importKey('raw', raw, {name:'AES-GCM'}, false, ['encrypt','decrypt'])
}

export default function ChatPage(){
  const [messages, setMessages] = useState<Msg[]>([])
  const [ws, setWs] = useState<WebSocket | null>(null)
  const [e2eeB64, setE2EeB64] = useState<string | null>(null)
  const [e2eeKey, setE2EeKey] = useState<CryptoKey | null>(null)
  const username = 'أنا'
  const room = 'general'
  const wsUrl = process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8080/ws'
  const apiBase = process.env.NEXT_PUBLIC_API_BASE || 'http://localhost:8000'

  useEffect(()=>{
    const sock = new WebSocket(`${wsUrl}?room=${room}&user=${encodeURIComponent(username)}`)
    sock.onopen = ()=>{ /* ready */ }
    sock.onmessage = (ev)=>{
      try{
        const data = JSON.parse(ev.data)
        if(data.type==='message'){
          setMessages(m=>[...m, data.payload])
        }else if(data.type==='init'){
          fetch(`${apiBase}/messages/${room}`).then(r=>r.json()).then(h=> setMessages(h || []))
        }
      }catch{}
    }
    setWs(sock); return ()=> sock.close()
  },[])

  useEffect(()=>{
    const saved = localStorage.getItem('ahla:e2ee')
    if(saved){ setE2EeB64(saved); importKey(saved).then(setE2EeKey).catch(()=>{}) }
  },[])

  async function enableE2EE(){
    const {key, b64} = await genKey()
    setE2EeKey(key); setE2EeB64(b64)
    localStorage.setItem('ahla:e2ee', b64)
    alert('تم تفعيل الوضع الخاص.
شارك هذا المفتاح سريًا لمن ترغب بالمحادثة الخاصة:\n'+b64)
  }
  function disableE2EE(){
    setE2EeKey(null); setE2EeB64(null)
    localStorage.removeItem('ahla:e2ee')
    alert('تم إيقاف الوضع الخاص.')
  }

  async function encrypt(text:string){
    if(!e2eeKey) return undefined
    const iv = crypto.getRandomValues(new Uint8Array(12))
    const enc = await crypto.subtle.encrypt({name:'AES-GCM', iv}, e2eeKey, new TextEncoder().encode(text))
    return { v:1, alg:'AES-GCM', iv: btoa(String.fromCharCode(...iv)), ct: btoa(String.fromCharCode(...new Uint8Array(enc))) }
  }
  async function decrypt(enc:any){
    if(!e2eeKey || !enc?.ct || !enc?.iv) return undefined
    try{
      const iv = Uint8Array.from(atob(enc.iv), c=>c.charCodeAt(0))
      const ct = Uint8Array.from(atob(enc.ct), c=>c.charCodeAt(0))
      const dec = await crypto.subtle.decrypt({name:'AES-GCM', iv}, e2eeKey, ct)
      return new TextDecoder().decode(dec)
    }catch{ return undefined }
  }

  async function onSend(text:string){
    const payload:Msg = { id: uid(), user: username, text, ts: Date.now() }
    let outgoing:any = payload
    const enc = await encrypt(text)
    if(enc){ outgoing = { ...payload, text: undefined, enc } }
    ws?.send(JSON.stringify({ type:'message', payload: outgoing, room }))
    setMessages(m=>[...m, outgoing])
    fetch(`${apiBase}/messages/${room}`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(outgoing)})
      .catch(()=>{})
  }

  return (
    <div className="min-h-screen grid grid-rows-[auto,1fr,auto] bg-[url('data:image/svg+xml,<svg xmlns=\'http://www.w3.org/2000/svg\' viewBox=\'0 0 10 10\'><circle cx=\'1\' cy=\'1\' r=\'.5\' fill=\'%23dcdcdc\' opacity=\'0.3\'/></svg>')]">
      <header className="h-14 flex items-center justify-between px-4 bg-white/70 backdrop-blur-md shadow-glass">
        <div className="font-semibold text-ahla-green">أهلا — محادثة</div>
        <div className="text-xs text-gray-600 flex items-center gap-3">
          <span>غرفة: {room}</span>
          <button onClick={()=> e2eeKey ? disableE2EE() : enableE2EE()} className="px-3 py-1 rounded-lg border">
            {e2eeKey ? '🔒 خاص مفعّل' : 'تفعيل الخاص 🔐'}
          </button>
        </div>
      </header>
      <ChatList messages={messages} decrypt={decrypt}/>
      <MessageInput onSend={onSend} encryptEnabled={!!e2eeKey}/>
    </div>
  )
}
