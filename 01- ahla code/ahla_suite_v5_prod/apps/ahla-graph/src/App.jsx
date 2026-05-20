import React,{useState} from 'react'
export default function App(){ const [src,setSrc]=useState('عنوان\n---\nنص الشريحة الثانية'); const slides=src.split(/\n---\n/)
  return(<><header><div className="brand">Ahla Graph</div><div>شرائح من نص</div></header>
  <main><div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:16}}>
  <div className="card"><h3>المحرّر</h3><textarea rows={16} style={{width:'100%'}} value={src} onChange={e=>setSrc(e.target.value)}/><p>افصل الشرائح بـ <code>---</code></p></div>
  <div className="card"><h3>المعاينة</h3>{slides.map((s,i)=>(<div key={i} style={{padding:16,marginBottom:12,background:'#E9F6F1',borderRadius:12}}>
  <h2>{s.split('\n')[0]}</h2><p>{s.split('\n').slice(1).join('\n')}</p></div>))}</div></div></main></>)
}