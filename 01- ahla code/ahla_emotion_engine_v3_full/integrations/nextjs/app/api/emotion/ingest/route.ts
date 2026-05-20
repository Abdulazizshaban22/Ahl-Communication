import { NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'

export async function POST(req: Request) {
  const body = await req.json()
  const r = await fetch(process.env.NEXT_PUBLIC_EMOTION_ENGINE_URL + '/analyze', {
    method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(body)
  })
  const analysis = await r.json()

  await prisma.messageAnalysis.create({
    data: {
      chatId: body.chat_id, messageId: body.message_id, authorId: body.author_id, text: body.text,
      sentiment: analysis.sentiment, toxicity: analysis.toxicity,
      topEmotions: analysis.top_emotions, flags: analysis.flags, suggestions: analysis.suggestions
    }
  })
  await prisma.conversationState.upsert({
    where: { chatId: body.chat_id },
    update: { lastSentiment: analysis.sentiment, lastTopEmotion: (analysis.top_emotions?.[0] ?? {}) },
    create: { chatId: body.chat_id, lastSentiment: analysis.sentiment, lastTopEmotion: (analysis.top_emotions?.[0] ?? {}) }
  })

  return NextResponse.json({ ok: true, analysis })
}
