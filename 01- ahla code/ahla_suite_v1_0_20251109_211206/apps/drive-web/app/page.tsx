
'use client'
import { useEffect, useState } from 'react'
import { encryptFile } from '../lib/encrypt'

export default function Drive(){
  const [list,setList]=useState<any[]>([])
  const refresh=()=> fetch('/api/drive/list').then(r=>r.json()).then(setList)
  useEffect(()=>{ refresh() },[])
  const onFile=async (e:any)=>{
    const f=e.target.files?.[0]; if(!f) return
    const { blob } = await encryptFile(f)
    const form=new FormData(); form.append('file', new File([blob], f.name+'.enc'))
    await fetch('/api/drive/upload',{ method:'POST', body:form })
    refresh()
  }
  return <main style={{fontFamily:'system-ui',padding:16,maxWidth:800,margin:'0 auto'}}>
    <h1>Ahla Drive</h1>
    <input type="file" onChange={onFile}/>
    <ul>{list.map(x=><li key={x.name}><a href={x.url} target="_blank">{x.name}</a></li>)}</ul>
  </main>
}
