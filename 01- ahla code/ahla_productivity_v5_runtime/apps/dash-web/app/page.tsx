'use client'
export default function Dash(){
  const url = process.env.NEXT_PUBLIC_SUPERSET_URL || 'http://localhost:8088'
  return (<main style={{padding:24}}>
    <h1>Ahla Dash</h1>
    <p>Public dashboard embedding (see Superset docs for CSP/config).</p>
    <iframe src={url} style={{width:'100%',height:620,border:'1px solid #ddd'}} />
  </main>)
}
