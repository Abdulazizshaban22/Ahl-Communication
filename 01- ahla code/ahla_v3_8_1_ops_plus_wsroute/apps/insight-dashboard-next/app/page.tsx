'use client'
import { useEffect, useMemo, useRef, useState } from 'react'

export default function Page() {
  const [snap, setSnap] = useState<any|null>(null)
  const [status, setStatus] = useState('connecting')
  const wsRef = useRef<WebSocket|null>(null)

  const wsUrl = useMemo(() => {
    const proto = location.protocol === 'https:' ? 'wss' : 'ws'
    const host = location.host
    return `${proto}://${host}/api/live`
  }, [])

  useEffect(() => {
    const ws = new WebSocket(wsUrl)
    wsRef.current = ws
    ws.onopen = () => setStatus('live')
    ws.onclose = () => setStatus('closed')
    ws.onerror = () => setStatus('error')
    ws.onmessage = (ev) => {
      try { setSnap(JSON.parse(ev.data)) } catch (e) {}
    }
    return () => { ws.close() }
  }, [wsUrl])

  return (
    <main style={{padding:'24px'}}>
      <h1 style={{fontSize:'28px', marginBottom:8}}>لوحة الذكاء اللحظي — Ahla Intelligence Live</h1>
      <div style={{opacity:0.7, marginBottom:16}}>WebSocket: {status}</div>

      <div style={{display:'grid', gridTemplateColumns:'1.2fr 0.8fr', gap:16}}>
        <section style={{background:'#10131a', padding:16, borderRadius:12}}>
          <h2 style={{marginBottom:8}}>🗣️ النصوص الحيّة (ASR)</h2>
          <div style={{height:260, overflow:'auto', lineHeight:1.6}}>
            {snap?.asr?.slice(-50).reverse().map((x:any, i:number) => (
              <div key={i} style={{opacity:0.9}}>{x.text || JSON.stringify(x)}</div>
            ))}
          </div>
        </section>

        <section style={{background:'#10131a', padding:16, borderRadius:12}}>
          <h2 style={{marginBottom:8}}>❤️ المزاج اللحظي (Emotion)</h2>
          <div style={{display:'flex', gap:12, flexWrap:'wrap'}}>
            {snap?.emotion?.slice(-10).reverse().map((x:any, i:number) => (
              <div key={i} style={{background:'#161b22', padding:'8px 10px', borderRadius:10}}>
                {x.label || x.sentiment}: {(x.score ?? 0).toFixed(2)}
              </div>
            ))}
          </div>
          <div style={{marginTop:12}}>الاقتراحات الأخيرة:</div>
          <ul style={{marginTop:6}}>
            {snap?.suggestions?.slice(-8).reverse().map((x:any, i:number) => (
              <li key={i} style={{opacity:0.9}}>{x.text || x.title || JSON.stringify(x)}</li>
            ))}
          </ul>
        </section>
      </div>

      <section style={{background:'#10131a', padding:16, borderRadius:12, marginTop:16}}>
        <h2>📈 مؤشرات فورية</h2>
        <div style={{display:'flex', gap:24, flexWrap:'wrap'}}>
          <KPI label="ASR msgs" value={snap?.kpi?.cnt_asr ?? 0} />
          <KPI label="Emotion msgs" value={snap?.kpi?.cnt_emotion ?? 0} />
          <KPI label="Suggestions msgs" value={snap?.kpi?.cnt_suggestions ?? 0} />
        </div>
      </section>
    </main>
  )
}

function KPI({label, value}:{label:string, value:number}){
  return (
    <div style={{background:'#161b22', padding:'12px 14px', borderRadius:10}}>
      <div style={{opacity:0.7, marginBottom:6}}>{label}</div>
      <div style={{fontSize:26, fontWeight:700}}>{value}</div>
    </div>
  )
}
