import http from 'http'
import express from 'express'
import { WebSocketServer } from 'ws'
import client from 'prom-client'
const app = express()
const server = http.createServer(app)
const wss = new WebSocketServer({ server, path:'/ws' })
const register = new client.Registry()
client.collectDefaultMetrics({ register })
const wsGauge = new client.Gauge({ name:'ahla_ws_connections', help:'active ws' })
register.registerMetric(wsGauge)
app.get('/metrics', async (_req,res)=>{ res.set('Content-Type', register.contentType); res.end(await register.metrics()) })
wss.on('connection', (ws)=>{ wsGauge.set(wss.clients.size); ws.on('message', d=>{ try{ const m=JSON.parse(d); if(m.type==='message'){ wss.clients.forEach(c=>c.send(JSON.stringify({type:'message',payload:m.payload}))) } }catch{} }); ws.on('close',()=>wsGauge.set(wss.clients.size)) })
server.listen(process.env.WS_PORT||8080, ()=> console.log('chat-ws on', process.env.WS_PORT||8080))
