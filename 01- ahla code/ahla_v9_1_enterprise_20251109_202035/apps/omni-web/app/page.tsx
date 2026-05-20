const base = "/omni";
export default function Page(){
  const path = "/"
  return (<main style={padding:24,fontFamily:'system-ui'}>
    <h1>Ahla Omni — Portal</h1>
    <p>Welcome to Ahla Omni — Portal. Enterprise-ready shell.</p>
    <ul>
      <li><a href="/chat">Chat</a> · <a href="/meet">Meet</a> · <a href="/drive">Drive</a> · <a href="/biz">Business</a> · <a href="/omni">Omni</a> · <a href="/mail">Mail</a></li>
    </ul>

  <div style={{marginTop:12}}>
    <a href={`${process.env.NEXT_PUBLIC_KC_URL}/realms/${process.env.NEXT_PUBLIC_KC_REALM}/protocol/openid-connect/auth?client_id=${process.env.NEXT_PUBLIC_KC_CLIENT}&response_type=code&redirect_uri=${encodeURIComponent(typeof window!=='undefined'?window.location.origin+`${base}${path}`:'')}`}>
      Sign in with Keycloak
    </a>
  </div>

  </main>)
}
