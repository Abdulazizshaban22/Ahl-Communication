'use client'
import { signIn } from "next-auth/react"
export default function Signin(){
  return (<main style={{padding:24,fontFamily:'system-ui'}}>
    <h1>Sign in</h1>
    <button onClick={()=>signIn('keycloak')}>Continue with Keycloak</button>
  </main>)
}