import React,{useState,useEffect} from 'react'
export default function App(){ const [text,setText]=useState(localStorage.getItem('notes')||''); useEffect(()=>localStorage.setItem('notes',text),[text])
  return(<><header><div className="brand">Ahla Notes</div><div>حفظ تلقائي</div></header>
  <main><div className="card"><textarea rows={18} style={{width:'100%'}} value={text} onChange={e=>setText(e.target.value)} placeholder="اكتب ملاحظاتك"/></div></main></>)
}