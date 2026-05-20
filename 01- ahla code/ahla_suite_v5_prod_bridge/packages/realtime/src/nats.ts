// Simple browser client using nats.ws (loaded in app via ESM / CDN in real build)
export async function connectNats(url: string){
  const { connect } = await import('https://cdn.skypack.dev/nats.ws')  // for demo; in prod bundle nats.js with ws
  const nc = await connect({ servers: url })
  return nc
}
