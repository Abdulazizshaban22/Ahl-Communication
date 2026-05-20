'use client'
import {useEffect, useRef, useState} from 'react'
export default function Page(){
  const [room,setRoom]=useState('demo')
  const localRef = useRef<HTMLVideoElement>(null)
  const remoteRef = useRef<HTMLVideoElement>(null)
  const pcRef = useRef<RTCPeerConnection|null>(null)
  const wsRef = useRef<WebSocket|null>(null)

  async function start(){
    const pc = new RTCPeerConnection({iceServers:[{urls:[process.env.NEXT_PUBLIC_TURN!],username:process.env.NEXT_PUBLIC_TURN_USER!,credential:process.env.NEXT_PUBLIC_TURN_PASS!}]})
    pc.ontrack = (ev)=>{ if(remoteRef.current){ remoteRef.current.srcObject = ev.streams[0] } }
    pcRef.current = pc

    const stream = await navigator.mediaDevices.getUserMedia({audio:true, video:true})
    stream.getTracks().forEach(t=>pc.addTrack(t, stream))
    if(localRef.current) localRef.current.srcObject = stream

    const ws = new WebSocket(process.env.NEXT_PUBLIC_SIGNAL_URL!)
    wsRef.current = ws
    ws.onopen = async ()=>{
      ws.send(JSON.stringify({room}))
      const offer = await pc.createOffer()
      await pc.setLocalDescription(offer)
      ws.send(JSON.stringify({type:'offer', sdp: offer.sdp, room}))
    }
    ws.onmessage = async (e)=>{
      const msg = JSON.parse(e.data)
      if(msg.type==='answer'){
        await pc.setRemoteDescription({type:'answer', sdp: msg.sdp})
      }else if(msg.type==='offer'){
        await pc.setRemoteDescription({type:'offer', sdp: msg.sdp})
        const ans = await pc.createAnswer()
        await pc.setLocalDescription(ans)
        ws.send(JSON.stringify({type:'answer', sdp: ans.sdp, room}))
      }else if(msg.type==='ice'){
        try{ await pc.addIceCandidate(msg.c) }catch{}
      }
    }
    pc.onicecandidate = (ev)=>{
      if(ev.candidate){ ws.send(JSON.stringify({type:'ice', c: ev.candidate, room})) }
    }
  }

  return <main style={{maxWidth:960,margin:'24px auto',padding:16}}>
    <h2>Ahla Meet</h2>
    <input value={room} onChange={e=>setRoom(e.target.value)}/>
    <button onClick={start}>بدء</button>
    <div style={{display:'flex',gap:12,marginTop:12}}>
      <video ref={localRef} autoPlay muted playsInline style={{width:'50%'}}/>
      <video ref={remoteRef} autoPlay playsInline style={{width:'50%'}}/>
    </div>
  </main>
}
