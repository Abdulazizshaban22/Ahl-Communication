export default function ProtectedHome(){
  return (<main style={{padding:24,fontFamily:'system-ui'}}>
    <h1>Ahla Omni — Portal (Protected)</h1>
    <ul>
      <li><a href="/chat">Chat</a> · <a href="/meet">Meet</a> · <a href="/drive">Drive</a> · <a href="/biz">Business</a> · <a href="/mail">Mail</a></li>
    </ul>
    <a href="/omni/api/auth/signout">Sign out</a>
  </main>)
}