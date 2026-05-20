'use client'
import { useEffect, useRef, useState } from 'react'

const API = (typeof window!=='undefined' ? (window.location.origin + '/api/moments') : '')

export default function Moments(){
  const videoRef = useRef<HTMLVideoElement|null>(null)
  const [rec,setRec] = useState<MediaRecorder|null>(null)
  const [recording,setRecording] = useState(false)
  const [clips,setClips] = useState<{name:string,url:string,thumb?:string}[]>([])
  const chunks = useRef<Blob[]>([])

  useEffect(()=>{
    fetch(`${API}/list`).then(r=>r.json()).then(setClips).catch(()=>{})
  },[])

  const start = async ()=>{
    const stream = await navigator.mediaDevices.getUserMedia({ video:true, audio:true })
    if(videoRef.current) videoRef.current.srcObject = stream
    const r = new MediaRecorder(stream, { mimeType: 'video/webm' })
    r.ondataavailable = e=> { if(e.data.size>0) chunks.current.push(e.data) }
    r.onstop = async ()=>{
      const blob = new Blob(chunks.current, { type: 'video/webm' })
      chunks.current = []
      const form = new FormData()
      form.append('file', new File([blob], `moment_${Date.now()}.webm`, { type:'video/webm' }))
      const res = await fetch(`${API}/upload`, { method:'POST', body: form })
      const j = await res.json()
      setClips(prev=>[j,...prev])
    }
    r.start(); setRec(r); setRecording(true)
    setTimeout(()=>{ if(r.state==='recording'){ r.stop(); setRecording(false) } }, 60000) // حد 60 ثانية
  }
  const stop = ()=>{ rec?.stop(); setRecording(false) }

  return (
    <main style={{fontFamily:'system-ui',padding:16,maxWidth:860,margin:'0 auto'}}>
      <h1>Ahla Moments — مقاطع قصيرة</h1>
      <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:12}}>
        <section>
          <video ref={videoRef} autoPlay muted playsInline style={{width:'100%',border:'1px solid #ddd',borderRadius:8}}/>
          <div style={{marginTop:8,display:'flex',gap:8}}>
            {!recording && <button onClick={start}>بدء</button>}
            {recording && <button onClick={stop}>إيقاف</button>}
            <span style={{opacity:0.7}}>الحد الأقصى: 60 ثانية</span>
          </div>
        </section>
        <section>
          <h3>آخر المقاطع</h3>
          <ul>
            {clips.map(c=>(
              <li key={c.url} style={{marginBottom:8}}>
                <a href={c.url} target="_blank" rel="noreferrer">{c.name}</a>
                {c.thumb && <img src={c.thumb} alt="" style={{display:'block',maxWidth:180,marginTop:6,borderRadius:6}}/>}
              </li>
            ))}
          </ul>
        </section>
      </div>
      <p style={{fontSize:12,opacity:0.7,marginTop:8}}>يعتمد التسجيل على <code>MediaRecorder</code> ويمكن تحسينه باستخدام <code>WebCodecs</code> عند التوافر.</p>
    </main>
  )
}