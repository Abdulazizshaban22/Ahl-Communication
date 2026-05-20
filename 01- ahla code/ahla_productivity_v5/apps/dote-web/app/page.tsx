'use client'
import { useEffect } from 'react'
export default function Page(){
  useEffect(()=>{
    // In real app, load Luckysheet assets; here, show placeholder iframe or div
  },[])
  return <main style={{padding:24}}>
    <h1>Ahla Dote (Spreadsheet)</h1>
    <p>Embed Luckysheet here and sync via API.</p>
    <div style={{height:500,border:'1px dashed #aaa',display:'grid',placeItems:'center'}}>Luckysheet placeholder</div>
  </main>
}
