import { NextRequest, NextResponse } from 'next/server'
export async function POST(req: NextRequest){
  const {username,password} = await req.json()
  const res = NextResponse.json({ok:true})
  res.cookies.set('mail_user', username, { httpOnly:true, sameSite:'lax', path:'/' })
  res.cookies.set('mail_pass', password, { httpOnly:true, sameSite:'lax', path:'/' })
  return res
}
