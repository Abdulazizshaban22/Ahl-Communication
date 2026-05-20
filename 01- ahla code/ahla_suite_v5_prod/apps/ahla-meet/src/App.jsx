import React,{useRef,useState} from 'react'
export default function App(){
  const cam=useRef(), share=useRef(); const [err,setErr]=useState('')
  const startCam=async()=>{try{const s=await navigator.mediaDevices.getUserMedia({video:true,audio:true}); cam.current.srcObject=s; await cam.current.play()}catch(e){setErr(e.message)}}
  const startShare=async()=>{try{const s=await navigator.mediaDevices.getDisplayMedia({video:true}); share.current.srcObject=s; await share.current.play()}catch(e){setErr(e.message)}}
  return(<>
    <header><div className="brand">Ahla Meet</div><div>كاميرا + مشاركة شاشة (محلي)</div></header>
    <main>
      <div style={{display:'flex',gap:16,flexWrap:'wrap'}}>
        <div className="card"><h3>الكاميرا</h3><video ref={cam} playsInline muted style={{width:320,borderRadius:12,background:'#000'}}/>
          <div style={{marginTop:8}}><button className="btn" onClick={startCam}>تشغيل</button></div></div>
        <div className="card"><h3>مشاركة الشاشة</h3><video ref={share} playsInline muted style={{width:320,borderRadius:12,background:'#000'}}/>
          <div style={{marginTop:8}}><button className="btn" onClick={startShare}>ابدأ المشاركة</button></div></div>
      </div>{err&&<p style={{color:'crimson'}}>خطأ: {err}</p>}
    </main>
  </>)
}