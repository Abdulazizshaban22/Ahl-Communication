
'use client'
import { useState } from 'react'
export default function Drive(){
  const [files,setFiles]=useState<any[]>([])
  const upload=async (e:any)=>{
    const f=e.target.files[0]; if(!f) return
    const fd=new FormData(); fd.append('file', f)
    const r=await fetch('/api/drive/upload',{method:'POST', body:fd}).then(r=>r.json())
    setFiles(x=>[...x, r])
  }
  return <main style={{fontFamily:'system-ui',padding:16}}>
    <h1>Ahla Drive</h1>
    <input type="file" onChange={upload}/>
    <ul>{files.map((f,i)=><li key={i}><a href={f.url} target="_blank">{f.name}</a></li>)}</ul>
  </main>
}
