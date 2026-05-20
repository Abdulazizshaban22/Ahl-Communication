import { NextRequest, NextResponse } from 'next/server'
export async function POST(req: NextRequest){
  const {email,password} = await req.json()
  const base = process.env.STALWART_MGMT_URL || 'http://localhost:8080'
  const key = process.env.STALWART_API_KEY || ''
  try{
    // Stalwart Management API: create account
    const r = await fetch(`${base}/api/management/directory/accounts`, {
      method:'POST', headers:{'Authorization':`Bearer ${key}`,'Content-Type':'application/json'},
      body: JSON.stringify({ id: email, secrets: [password] })
    })
    if(!r.ok) throw new Error(`status ${r.status}`)
    return NextResponse.json({ok:true})
  }catch(e:any){
    return NextResponse.json({ok:false, error:e?.message||'failed'}, {status:500})
  }
}
