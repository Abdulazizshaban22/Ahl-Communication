import { NextResponse } from 'next/server'
import policy from '@/apps/web/integrations/config/policy.json'

export async function POST(req: Request) {
  const b = await req.json()
  const ctx = (b.context ?? 'personal') as 'personal'|'family'|'work'
  const p = (policy as any).contexts[ctx] || (policy as any).contexts['personal']

  // If analysis is not provided and policy is not on-device, call engine
  let analysis = b.analysis
  if (!analysis && !p.on_device) {
    const r = await fetch(process.env.NEXT_PUBLIC_EMOTION_ENGINE_URL + '/analyze', {
      method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(b)
    })
    analysis = await r.json()
  }

  // Decide what to persist
  const redacted = !p.store_raw_text
  const textToStore = redacted ? '__REDACTED__' : (b.text ?? '')

  // TODO: persist via Prisma (Message + MessageAnalysis + ConversationState)
  // This patch keeps API surface consistent and returns analysis/flags to UI.

  return NextResponse.json({ ok: true, analysis, redacted })
}