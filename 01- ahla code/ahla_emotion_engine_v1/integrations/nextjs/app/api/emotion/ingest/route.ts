import { NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import { analyzeMessage } from '@/lib/emotion-client'

export async function POST(req: Request) {
  const body = await req.json()
  const { chat_id, message_id, author_id, text, context } = body

  // Load last 10 analyses as history for rules
  const last = await prisma.messageAnalysis.findMany({
    where: { chatId: chat_id },
    take: 10,
    orderBy: { createdAt: 'desc' }
  })
  const history = last.map(i => ({
    sentiment: i.sentiment as any,
    toxicity: i.toxicity as any,
    top_emotions: i.topEmotions as any,
    flags: i.flags as any,
    suggestions: i.suggestions as any
  }))

  const analysis = await analyzeMessage({
    chat_id, message_id, author_id, text, context: context ?? null
  })

  // Persist
  await prisma.messageAnalysis.create({
    data: {
      chatId: chat_id,
      messageId: message_id,
      authorId: author_id,
      text,
      sentiment: analysis.sentiment,
      toxicity: analysis.toxicity,
      topEmotions: analysis.top_emotions,
      flags: analysis.flags,
      suggestions: analysis.suggestions
    }
  })

  // Update conversation_state rollup (simple example)
  await prisma.conversationState.upsert({
    where: { chatId: chat_id },
    update: { lastSentiment: analysis.sentiment, lastTopEmotion: analysis.top_emotions[0] || {} },
    create: { chatId: chat_id, lastSentiment: analysis.sentiment, lastTopEmotion: analysis.top_emotions[0] || {} }
  })

  return NextResponse.json({ ok: true, analysis })
}
