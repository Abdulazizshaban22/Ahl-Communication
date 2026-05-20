const base = "/chat";
export default function Page(){
  const path = "/"
  return (<main style={padding:24,fontFamily:'system-ui'}>
    <h1>Ahla Chat — Web</h1>
    <p>Welcome to Ahla Chat — Web. Enterprise-ready shell.</p>
    <ul>
      <li><a href="/chat">Chat</a> · <a href="/meet">Meet</a> · <a href="/drive">Drive</a> · <a href="/biz">Business</a> · <a href="/omni">Omni</a> · <a href="/mail">Mail</a></li>
    </ul>

  </main>)
}
