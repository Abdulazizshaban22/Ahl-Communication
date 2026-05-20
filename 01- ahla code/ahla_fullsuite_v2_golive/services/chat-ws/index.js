const { WebSocketServer } = require('ws');const PORT=process.env.PORT||8090;
const wss=new WebSocketServer({port:PORT});wss.on('connection',ws=>{ws.on('message',m=>{for(const c of wss.clients)if(c.readyState===1)c.send(m.toString());});});
console.log('Chat WS listening on',PORT);