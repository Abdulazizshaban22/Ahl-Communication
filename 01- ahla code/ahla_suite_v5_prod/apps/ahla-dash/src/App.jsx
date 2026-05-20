import React,{useEffect,useRef} from 'react'
import Chart from 'chart.js/auto'
export default function App(){ const cRef=useRef()
  useEffect(()=>{ const ctx=cRef.current.getContext('2d'); const ch=new Chart(ctx,{type:'line',
    data:{labels:['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],datasets:[{label:'Active Users',data:[12,19,11,23,18,30,28]}]},
    options:{responsive:true,maintainAspectRatio:false}}); return ()=>ch.destroy() },[])
  return(<><header><div className="brand">Ahla Dash</div><div>لوحة مؤشرات</div></header>
  <main><div className="card" style={{height:360}}><canvas ref={cRef} width="600" height="300"/></div></main></>)
}