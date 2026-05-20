import http from 'http'
import express from 'express'
import { WebSocketServer } from 'ws'
import client from 'prom-client'

const app = express()
const server = http.createServer(app)
const wss = new WebSocketServer({ server, path: '/ws' })

const WS_PORT = process.env.WS_PORT || 8080

// Prometheus metrics
const register = new client.Registry()
client.collectDefaultMetrics({ register })
const wsConnections = new client.Gauge({ name:'ahla_ws_connections', help:'Active WebSocket connections' })
register.registerMetric(wsConnections)
app.get('/metrics', async (_req, res) => {
  res.set('Content-Type', register.contentType)
  res.end(await register.metrics())
})

const rooms = new Map() // room -> Set<WebSocket>

function broadcast(room, msg){
  const set = rooms.get(room)
  if(!set) return
  for(const ws of set){
    if(ws.readyState===ws.OPEN){
      ws.send(JSON.stringify(msg))
    }
  }
}

wss.on('connection', (ws, req)=>{
  const url = new URL(req.url, `http://${req.headers.host}`)
  const room = url.searchParams.get('room') || 'general'
  const user = url.searchParams.get('user') || 'مستخدم'
  if(!rooms.has(room)) rooms.set(room, new Set())
  rooms.get(room).add(ws)
  wsConnections.set(wss.clients.size)

  ws.send(JSON.stringify({ type:'init', room }))

  ws.on('message', (data)=>{
    try{
      const m = JSON.parse(data.toString())
      if(m?.type==='message'){
        broadcast(room, { type:'message', payload: m.payload })
      }
    }catch(e){}
  })
  ws.on('close', ()=>{
    rooms.get(room)?.delete(ws)
    wsConnections.set(wss.clients.size)
  })
})

server.listen(WS_PORT, ()=> {
  console.log('WS server listening on', WS_PORT)
})
