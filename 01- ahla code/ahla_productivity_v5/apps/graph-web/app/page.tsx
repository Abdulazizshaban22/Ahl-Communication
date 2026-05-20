'use client'
import { useState } from 'react'
type Slide = { id:string; title:string; content:string }
export default function Page(){
  const [slides,setSlides]=useState<Slide[]>([{id:'1',title:'Title',content:'Welcome to Ahla Graph'}])
  return <main style={{padding:24}}>
    <h1>Ahla Graph</h1>
    <button onClick={()=>setSlides(s=>[...s,{id:String(s.length+1),title:'New',content:'…'}])}>Add Slide</button>
    <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:16, marginTop:16}}>
      {slides.map(s=>(<div key={s.id} style={{border:'1px solid #ddd',padding:12}}>
        <h3 contentEditable suppressContentEditableWarning>{s.title}</h3>
        <div contentEditable suppressContentEditableWarning>{s.content}</div>
      </div>))}
    </div>
  </main>
}
