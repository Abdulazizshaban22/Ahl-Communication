'use client'
import { useEffect, useState } from 'react'
import { nanoid } from 'nanoid'
const API = process.env.NEXT_PUBLIC_CONTENT_API || 'http://localhost:8001'

type Slide = { id:string; title:string; content:string }
export default function Graph(){
  const [slides,setSlides]=useState<Slide[]>([{id:nanoid(),title:'Title',content:'Welcome to Ahla Graph'}])

  async function save(){
    const payload = { id: 'deck-1', kind:'slide', title: slides[0]?.title || 'Deck', content: JSON.stringify(slides) }
    await fetch(`${API}/items`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) })
    alert('Saved!')
  }

  useEffect(()=>{ /* could load deck from API here */ },[])
  return <main style={{padding:24}}>
    <h1>Ahla Graph</h1>
    <button onClick={()=>setSlides(s=>[...s,{id:nanoid(),title:'New',content:'…'}])}>Add Slide</button>
    <button onClick={save} style={{marginLeft:8}}>Save Deck</button>
    <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:16, marginTop:16}}>
      {slides.map(s=>(<div key={s.id} style={{border:'1px solid #ddd',padding:12}}>
        <h3 contentEditable suppressContentEditableWarning>{s.title}</h3>
        <div contentEditable suppressContentEditableWarning>{s.content}</div>
      </div>))}
    </div>
  </main>
}
