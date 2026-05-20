'use client'
export function SmartNudge({ suggestions=[], onAccept }:{suggestions:string[], onAccept?:(s:string)=>void}){
  if(!suggestions.length) return null
  return <div style={{position:'fixed', left:'50%', transform:'translateX(-50%)', bottom:20, width:'min(90%,680px)',
    background:'#fff', border:'1px solid #eee', borderRadius:12, boxShadow:'0 8px 30px rgba(0,0,0,.08)', padding:12}}>
    <div style={{fontWeight:600, marginBottom:8}}>اقتراح لطيف</div>
    <ul style={{listStyle:'none', padding:0, margin:0}}>
      {suggestions.map((s,i)=>(
        <li key={i} style={{display:'flex', justifyContent:'space-between', alignItems:'center', gap:8, padding:'6px 0'}}>
          <span style={{fontSize:14}}>{s}</span>
          <button onClick={()=>onAccept?.(s)} style={{border:'1px solid #ddd', borderRadius:8, padding:'6px 10px'}}>استخدم</button>
        </li>
      ))}
    </ul>
  </div>
}