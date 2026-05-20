import { NextRequest, NextResponse } from 'next/server'
import { cookies } from 'next/headers'
const JMAP = process.env.JMAP_BASE_URL || 'http://localhost:8080/jmap'

export async function GET(req: NextRequest){
  const u = cookies().get('mail_user')?.value
  const p = cookies().get('mail_pass')?.value
  if(!u || !p) return NextResponse.json({error:'missing creds'}, {status:401})
  const ops = [ ["Email/query", { accountId: "u0", sort: [{property:"receivedAt", isAscending:false}], limit: 20 }, "a" ],
                ["Email/get", { accountId: "u0", properties: ["id","subject","from","receivedAt"], '#ids': { resultOf:"a", name:"Email/query", path:"/ids" } }, "b"] ]
  const res = await fetch(JMAP, {
    method:'POST',
    headers: { 'Content-Type':'application/json', 'Accept':'application/json; jmapVersion=rfc-8621', 'Authorization':'Basic '+Buffer.from(`${u}:${p}`).toString('base64') },
    body: JSON.stringify(ops)
  })
  if(!res.ok) return NextResponse.json({error:'jmap failed', status:res.status}, {status:502})
  const data = await res.json()
  // map to simple list
  const list = (data?.[1]?.[1]?.list||[]).map((m:any)=>({ id:m.id, subject:m.subject, from: m.from?.[0]?.name||m.from?.[0]?.email, receivedAt:m.receivedAt }))
  return NextResponse.json({items:list})
}
