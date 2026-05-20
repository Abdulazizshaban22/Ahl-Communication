import { NextResponse } from "next/server"
import { auth } from "@/auth.config"

export async function middleware(req: Request) {
  const session = await auth()
  const url = new URL(req.url)
  const protectedPrefixes = ["/dashboard","/app"]
  if (protectedPrefixes.some(p => url.pathname.startsWith(p))) {
    if (!session) return NextResponse.redirect(new URL("/api/auth/signin", req.url))
  }
  return NextResponse.next()
}

export const config = { matcher: ["/dashboard/:path*","/app/:path*"] }
