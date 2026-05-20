import React, {useState, useRef} from 'react'
import './style.css'
let tusClient=null; try{ tusClient=(await import('tus-js-client')).default }catch{}
export default function App(){
  const [mode,setMode]=useState('local'); const [tusURL,setTusURL]=useState(''); const [log,setLog]=useState([]); const fileRef=useRef()
  const push=(s)=>setLog(l=>[...l,s])
  const doUpload=()=>{
    const f=fileRef.current?.files?.[0]; if(!f){push('اختر ملفاً');return}
    if(mode==='tus' && tusClient && tusURL){
      const u=new tusClient.Upload(f,{endpoint:tusURL,metadata:{filename:f.name},
        onError:e=>push('خطأ: '+e),onProgress:(s,t)=>push(`رفع: ${((s/t)*100).toFixed(1)}%`),onSuccess:()=>push('تم الرفع ✅')});u.start()
    }else{
      const url=URL.createObjectURL(f); push(`محلي: ${f.name} (${(f.size/1024).toFixed(1)}KB)`); const a=document.createElement('a'); a.href=url; a.download=f.name; a.click()
    }
  }
  return(<>
    <header><div className="brand">Ahla Drive</div><div>رفع ملفات (محلي / tus)</div></header>
    <main>
      <div className="card" style={{display:'flex',gap:8,alignItems:'center',flexWrap:'wrap'}}>
        <select value={mode} onChange={e=>setMode(e.target.value)}><option value="local">محلي</option><option value="tus">tus</option></select>
        {mode==='tus'&&<input placeholder="http://localhost:1080/files/" value={tusURL} onChange={e=>setTusURL(e.target.value)} style={{minWidth:320}}/>}
        <input type="file" ref={fileRef}/><button className="btn" onClick={doUpload}>رفع</button>
      </div>
      <h3>السجل</h3><div className="card" style={{whiteSpace:'pre-wrap'}}>{log.join('\n')}</div>
    </main>
  </>)
}