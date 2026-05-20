export const runtime = 'edge'

function toJSON(v:any){ try { return JSON.stringify(v) } catch { return '{}' } }

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const gateway = searchParams.get('gateway') || process.env.GATEWAY_URL || 'http://localhost:8085'

  // @ts-ignore - WebSocketPair is available in Edge runtime
  const { 0: client, 1: server } = new WebSocketPair()
  ;(async () => {
    // Periodic polling of /snapshot and push over WS
    const interval = 1000
    while (true) {
      try {
        const r = await fetch(`${gateway}/snapshot`, { cache: 'no-store' })
        const json = await r.json()
        server.send(toJSON(json))
      } catch (e) {
        server.send(toJSON({ error: 'gateway_fetch_failed', message: String(e) }))
      }
      await new Promise(res => setTimeout(res, interval))
    }
  })()

  // @ts-ignore
  return new Response(null, { status: 101, webSocket: client })
}
