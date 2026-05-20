export default function Page(){
  return (<main style={{padding:24}}>
    <h1>Ahla Dash</h1>
    <p>Connect to Apache Superset via SSO and embed charts here.</p>
    <iframe src="http://localhost:8088" style={{width:'100%',height:600,border:'1px solid #ddd'}} />
  </main>)
}