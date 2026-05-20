'use client'
import {useState} from 'react'
export default function Page(){
  const [file,setFile]=useState<File|null>(null)
  const [path,setPath]=useState('uploads/example.bin')
  const [url,setUrl]=useState<string|undefined>()
  async function upload(){
    const res = await fetch(process.env.NEXT_PUBLIC_DRIVE_API!+'/presign',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({object_name:path,method:'put'})})
    const {url} = await res.json(); setUrl(url)
    if(file){
      await fetch(url,{method:'PUT',body:file})
      alert('uploaded!')
    }
  }
  return <main style={{maxWidth:720,margin:'24px auto',padding:16}}>
    <h2>Ahla Drive</h2>
    <input value={path} onChange={e=>setPath(e.target.value)} style={{width:'100%'}}/>
    <input type="file" onChange={e=>setFile(e.target.files?.[0]||null)}/>
    <button onClick={upload}>رفع</button>
    {url && <p>Presigned URL: <a href={url} target="_blank">open</a></p>}
    <p>MinIO console: <a href={process.env.NEXT_PUBLIC_MINIO_CONSOLE!} target="_blank">{process.env.NEXT_PUBLIC_MINIO_CONSOLE}</a></p>
  </main>
}
