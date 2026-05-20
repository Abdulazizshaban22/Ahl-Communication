import http from 'http'
import express from 'express'
import { WebSocketServer } from 'ws'
import client from 'prom-client'
import jwt from 'jsonwebtoken'
const app = express()
const server = http.createServer(app)
const wss = new WebSocketServer({ server, path:'/ws' })
const register = new client.Registry()
client.collectDefaultMetrics({ register })
const wsGauge = new client.Gauge({ name:'ahla_ws_connections', help:'active ws' })
register.registerMetric(wsGauge)
app.get('/metrics', async (_req,res)=>{ res.set('Content-Type', register.contentType); res.end(await register.metrics()) })

const ENFORCE_JWT = (process.env.ENFORCE_JWT||'false').toLowerCase()==='true'

wss.on('connection', (ws, req)=>{
  wsGauge.set(wss.clients.size)
  if(ENFORCE_JWT){
    const url = new URL(req.url, `http://${req.headers.host}`)
    const token = url.searchParams.get('token')
    if(!token){ ws.close(1008, 'missing token'); return }
    try{ jwt.decode(token) }catch{ ws.close(1008,'bad token'); return }
  }
  ws.on('message', d=>{
    let m; try{ m=JSON.parse(d) }catch{ return }
    if(m.type==='message'){
      wss.clients.forEach(c=> c.readyState===1 && c.send(JSON.stringify({type:'message',payload:m.payload})))
    }
  })
  ws.on('close',()=> wsGauge.set(wss.clients.size))
})
server.listen(process.env.WS_PORT||8080, ()=> console.log('chat-ws on', process.env.WS_PORT||8080))
