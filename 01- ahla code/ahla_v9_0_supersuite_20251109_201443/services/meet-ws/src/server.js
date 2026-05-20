import http from 'http'
import express from 'express'
import { WebSocketServer } from 'ws'
import client from 'prom-client'
const app = express()
const server = http.createServer(app)
const wss = new WebSocketServer({ server, path:'/signal' })
const register = new client.Registry()
client.collectDefaultMetrics({ register })
const wsGauge = new client.Gauge({ name:'ahla_meet_ws', help:'active meet ws' })
register.registerMetric(wsGauge)
app.get('/metrics', async (_req,res)=>{ res.set('Content-Type', register.contentType); res.end(await register.metrics()) })

const rooms = new Map() // room -> Set<WebSocket>

wss.on('connection',(ws,req)=>{
  wsGauge.set(wss.clients.size)
  const url = new URL(req.url, `http://${req.headers.host}`)
  const room = url.searchParams.get('room')||'default'
  if(!rooms.has(room)) rooms.set(room,new Set())
  rooms.get(room).add(ws)
  ws.on('message', (d)=>{
    let m; try{ m = JSON.parse(d.toString()) }catch{return}
    // relay signaling messages (offer/answer/candidate)
    for(const peer of rooms.get(room)){
      if(peer!==ws && peer.readyState===peer.OPEN){
        peer.send(JSON.stringify(m))
      }
    }
  })
  ws.on('close', ()=>{ rooms.get(room)?.delete(ws); wsGauge.set(wss.clients.size) })
})

server.listen(process.env.MEET_PORT||8090, ()=> console.log('meet-ws on', process.env.MEET_PORT||8090))
