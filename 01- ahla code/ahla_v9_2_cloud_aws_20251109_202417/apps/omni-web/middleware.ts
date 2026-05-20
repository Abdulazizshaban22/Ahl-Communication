import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(req: NextRequest) {
  const publicPaths = ['/omni', '/omni/signin', '/omni/api/auth']
  const isPublic = publicPaths.some((p)=> req.nextUrl.pathname.startsWith(p))
  const session = req.cookies.get('__Secure-next-auth.session-token') || req.cookies.get('next-auth.session-token')
  if (!isPublic && !session) {
    const url = req.nextUrl.clone()
    url.pathname = '/omni/signin'
    url.searchParams.set('callbackUrl', req.nextUrl.pathname)
    return NextResponse.redirect(url)
  }
  return NextResponse.next()
}
export const config = { matcher: ['/omni/:path*'] }