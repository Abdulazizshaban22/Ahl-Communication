import express from 'express';
import cors from 'cors';
import http from 'http';
import { Server } from 'socket.io';

const app = express();
app.use(cors());
app.get('/health', (_,res)=>res.json({ok:true, service:'meet-signaling'}));

const server = http.createServer(app);
const io = new Server(server, { path: '/meet/socket' });

io.on('connection', (socket)=>{
  socket.on('offer', (payload)=> socket.broadcast.emit('offer', payload));
  socket.on('answer', (payload)=> socket.broadcast.emit('answer', payload));
  socket.on('ice-candidate', (payload)=> socket.broadcast.emit('ice-candidate', payload));
});

server.listen(3001, ()=>console.log('meet-signaling:3001'));
