import { NextResponse } from 'next/server'

function verifySignature(req: Request){
  const secret = process.env.LABEL_STUDIO_WEBHOOK_SECRET || ''
  // Simple shared-secret header verification
  const hdr = (req.headers.get('x-labelstudio-signature') || '').trim()
  return secret && hdr && hdr === secret
}

export async function POST(req: Request){
  if (!verifySignature(req)) return new Response('forbidden', { status: 403 })
  const payload = await req.json()

  // Persist to disk (inbox) for training pipeline
  try {
    const dir = '/tmp/labelstudio/inbox'
    await (await import('fs/promises')).mkdir(dir, { recursive: true })
    const fname = `${dir}/${Date.now()}_${payload.action || 'event'}.json`
    await (await import('fs/promises')).writeFile(fname, JSON.stringify(payload))
  } catch {}

  // Optionally trigger internal queue or retrain job (left as TODO hook)
  return NextResponse.json({ ok: true })
}
