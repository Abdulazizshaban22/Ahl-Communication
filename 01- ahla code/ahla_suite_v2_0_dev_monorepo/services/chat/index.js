import express from 'express';
import { WebSocketServer } from 'ws';
import Redis from 'ioredis';

const app = express();
const server = app.listen(3000, ()=>console.log('chat:http 3000'));
const wss = new WebSocketServer({ server, path: '/ws' });

const REDIS_URL = process.env.REDIS_URL || 'redis://redis:6379';
const redis = new Redis(REDIS_URL);

app.get('/health', (req,res)=>res.json({ok:true, service:'chat'}));

wss.on('connection', (ws)=>{
  ws.send(JSON.stringify({type:'welcome', at: Date.now()}));
  ws.on('message', (raw)=>{
    try{
      const msg = JSON.parse(raw);
      if (msg.type === 'ping') return ws.send(JSON.stringify({type:'pong'}));
      // Broadcast to all
      wss.clients.forEach(client=>{
        if (client.readyState === 1) client.send(JSON.stringify({type:'msg', ...msg, at: Date.now()}));
      });
      // Publish to Redis channel for demo
      redis.publish('chat:events', JSON.stringify(msg));
    } catch(e){
      ws.send(JSON.stringify({type:'error', error: e.message}));
    }
  });
});
