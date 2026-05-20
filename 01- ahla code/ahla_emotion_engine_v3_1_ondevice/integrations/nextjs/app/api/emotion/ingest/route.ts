import { NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import policy from '@/integrations/nextjs/config/policy.json'

export async function POST(req: Request) {
  const b = await req.json()
  const ctx = b.context as 'personal'|'family'|'work' || 'personal'
  const p = (policy as any).contexts[ctx] || (policy as any).contexts['personal']

  // If client did on-device analysis, it can attach `analysis` directly.
  let analysis = b.analysis
  if (!analysis && !p.on_device) {
    const r = await fetch(process.env.NEXT_PUBLIC_EMOTION_ENGINE_URL + '/analyze', {
      method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(b)
    })
    analysis = await r.json()
  }

  // Decide what to persist
  const textToStore = p.store_raw_text ? (b.text as string) : '__REDACTED__'

  await prisma.messageAnalysis.create({
    data: {
      chatId: b.chat_id, messageId: b.message_id, authorId: b.author_id, text: textToStore,
      sentiment: analysis.sentiment, toxicity: analysis.toxicity,
      topEmotions: analysis.top_emotions, flags: analysis.flags, suggestions: analysis.suggestions
    }
  })
  await prisma.conversationState.upsert({
    where: { chatId: b.chat_id },
    update: { lastSentiment: analysis.sentiment, lastTopEmotion: (analysis.top_emotions?.[0] ?? {}) },
    create: { chatId: b.chat_id, lastSentiment: analysis.sentiment, lastTopEmotion: (analysis.top_emotions?.[0] ?? {}) }
  })
  return NextResponse.json({ ok: true, analysis, redacted: !p.store_raw_text })
}
