
'use client'
import { useEffect, useRef, useState } from 'react'

export default function Meet(){
  const localRef = useRef<HTMLVideoElement>(null)
  const remoteRef = useRef<HTMLVideoElement>(null)
  const [room,setRoom]=useState('room1')
  const pcRef = useRef<RTCPeerConnection|null>(null)
  const wsRef = useRef<WebSocket|null>(null)

  useEffect(()=>{
    (async ()=>{
      const stream = await navigator.mediaDevices.getUserMedia({audio:true,video:true})
      if(localRef.current){ localRef.current.srcObject = stream; await localRef.current.play() }
      const pc = new RTCPeerConnection()
      stream.getTracks().forEach(t=>pc.addTrack(t, stream))
      pc.ontrack = e => { if(remoteRef.current){ remoteRef.current.srcObject = e.streams[0]; remoteRef.current.play() } }
      pcRef.current = pc

      const ws = new WebSocket((location.origin.replace(/^http/,'ws'))+'/api/meet/ws?room='+room)
      ws.onmessage = async (ev)=>{
        const {type,data} = JSON.parse(ev.data)
        if(type==='offer'){ await pc.setRemoteDescription(data); const ans=await pc.createAnswer(); await pc.setLocalDescription(ans); ws.send(JSON.stringify({type:'answer', data:ans})) }
        if(type==='answer'){ await pc.setRemoteDescription(data) }
        if(type==='candidate'){ try{ await pc.addIceCandidate(data) }catch{} }
      }
      wsRef.current = ws

      pc.onicecandidate = (ev)=>{ if(ev.candidate) ws.send(JSON.stringify({type:'candidate', data:ev.candidate})) }

      const offer = await pc.createOffer(); await pc.setLocalDescription(offer)
      ws.addEventListener('open', ()=> ws.send(JSON.stringify({type:'offer', data:offer})))
    })()
    return ()=>{ wsRef.current?.close(); pcRef.current?.close() }
  },[room])

  return <main style={{fontFamily:'system-ui',padding:16}}>
    <h1>Ahla Meet</h1>
    <div style={{display:'flex',gap:8,marginBottom:8}}>
      <input value={room} onChange={e=>setRoom(e.target.value)} style={{padding:8}}/>
      <small>WebRTC demo — signaling via WebSocket</small>
    </div>
    <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:12}}>
      <video ref={localRef} muted playsInline style={{width:'100%',borderRadius:12,background:'#000'}}/>
      <video ref={remoteRef} playsInline style={{width:'100%',borderRadius:12,background:'#000'}}/>
    </div>
  </main>
}
