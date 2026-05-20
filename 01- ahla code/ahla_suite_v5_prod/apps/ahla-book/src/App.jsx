import React,{useRef} from 'react'
export default function App(){ const ref=useRef(); const cmd=(c)=>document.execCommand(c,false,null)
  return(<><header><div className="brand">Ahla Book</div><div>محرّر نص منسق</div></header>
  <main><div className="card" style={{display:'flex',gap:8,flexWrap:'wrap',marginBottom:12}}>
  <button className="btn" onClick={()=>cmd('bold')}>غامق</button><button className="btn" onClick={()=>cmd('italic')}>مائل</button>
  <button className="btn" onClick={()=>cmd('underline')}>تسطير</button><button className="btn" onClick={()=>cmd('insertUnorderedList')}>نقاط</button></div>
  <div className="card" contentEditable ref={ref} style={{minHeight:300}}>اكتب مستندك هنا…</div></main></>)
}