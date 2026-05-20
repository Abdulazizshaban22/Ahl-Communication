import { setupWSConnection } from 'y-websocket/bin/utils.js';
import http from 'http'; import WebSocket, { WebSocketServer } from 'ws';

const port = process.env.PORT || 1234;
const server = http.createServer((_, res)=> res.end('ok'));
const wss = new WebSocketServer({ server });

wss.on('connection', (ws, req) => setupWSConnection(ws, req, { gc: true }));
server.listen(port, ()=> console.log('collab-gateway on', port));
