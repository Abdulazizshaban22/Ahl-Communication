'use client'
import { useEffect } from 'react'
const API = process.env.NEXT_PUBLIC_CONTENT_API || 'http://localhost:8001'
export default function Dote(){
  useEffect(()=>{
    // placeholder - actual init done by scripts in _document
  },[])

  async function saveSheet(){
    // @ts-ignore
    const data = window.luckysheet?.getAllSheets?.() || []
    await fetch(`${API}/items`, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ id:'sheet-1', kind:'sheet', title:'Sheet1', content: JSON.stringify(data) }) })
    alert('Saved!')
  }

  return <main style={{padding:24}}>
    <h1>Ahla Dote (Spreadsheet)</h1>
    <button onClick={saveSheet}>Save Sheet</button>
    <div id="luckysheet" style={{height:600, border:'1px solid #ddd', marginTop:12}}></div>
  </main>
}
