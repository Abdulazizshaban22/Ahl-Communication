import React,{useState} from 'react'
export default function App(){ const [rows,setRows]=useState([[1,2],[3,4]])
  const addRow=()=>setRows(r=>[...r,Array(r[0].length).fill(0)]); const addCol=()=>setRows(r=>r.map(x=>[...x,0]))
  const setCell=(ri,ci,val)=>setRows(r=>r.map((row,i)=>i===ri?row.map((v,j)=>j===ci?Number(val||0):v):row))
  const sumCol=(ci)=>rows.reduce((a,r)=>a+Number(r[ci]||0),0)
  return(<><header><div className="brand">Ahla Dote</div><div>جداول ومجاميع</div></header>
  <main><div className="card" style={{overflowX:'auto'}}><table><tbody>
  {rows.map((r,ri)=>(<tr key={ri}>{r.map((v,ci)=>(<td key={ci}><input value={v} onChange={e=>setCell(ri,ci,e.target.value)} style={{width:80}}/></td>))}</tr>))}
  <tr>{rows[0].map((_,ci)=>(<td key={'s'+ci}><b>Σ {sumCol(ci)}</b></td>))}</tr></tbody></table>
  <div style={{marginTop:8,display:'flex',gap:8}}><button className="btn" onClick={addRow}>أضف صف</button><button className="btn" onClick={addCol}>أضف عمود</button></div></div></main></>)
}