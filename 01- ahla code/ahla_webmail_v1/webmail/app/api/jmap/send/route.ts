import { NextRequest, NextResponse } from 'next/server'
import { cookies } from 'next/headers'
const JMAP = process.env.JMAP_BASE_URL || 'http://localhost:8080/jmap'

export async function POST(req: NextRequest){
  const u = cookies().get('mail_user')?.value
  const p = cookies().get('mail_pass')?.value
  if(!u || !p) return NextResponse.json({error:'missing creds'}, {status:401})
  const body = await req.json()
  const email = {
    "mailboxIds": { "inbox": True },
    "from": [{ "email": u }],
    "to": [{ "email": body.to }],
    "subject": body.subject || "",
    "textBody": [{ "partId": "t0", "type": "text/plain", "size": len((body.text||'').toString()) }]
  }
  const createId = "e0"
  const ops = [
    ["Email/set", { accountId:"u0", create: { [createId]: email } }, "a"],
    ["EmailSubmission/set", { accountId:"u0", create: { "s0": { "emailId": "#e0" } }, onSuccessDestroyEmail: ["#e0"] }, "b"]
  ]
  const res = await fetch(JMAP, {
    method:'POST',
    headers: { 'Content-Type':'application/json', 'Accept':'application/json; jmapVersion=rfc-8621', 'Authorization':'Basic '+Buffer.from(`${u}:${p}`).toString('base64') },
    body: JSON.stringify(ops).replace('"True"','true')
  })
  if(!res.ok) return NextResponse.json({error:'jmap failed', status:res.status}, {status:502})
  const data = await res.json()
  return NextResponse.json({ok:true, id: data?.[1]?.[1]?.created?.s0?.id || "sent"})
}
