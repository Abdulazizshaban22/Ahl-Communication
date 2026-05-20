import { NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
export async function POST(req: Request) {
  const b = await req.json()
  const r = await fetch(process.env.NEXT_PUBLIC_EMOTION_ENGINE_URL + '/analyze', {
    method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(b)
  })
  const analysis = await r.json()
  await prisma.messageAnalysis.create({
    data: {
      chatId: b.chat_id, messageId: b.message_id, authorId: b.author_id, text: b.text,
      sentiment: analysis.sentiment, toxicity: analysis.toxicity,
      topEmotions: analysis.top_emotions, flags: analysis.flags, suggestions: analysis.suggestions
    }
  })
  return NextResponse.json({ok:true, analysis})
}
