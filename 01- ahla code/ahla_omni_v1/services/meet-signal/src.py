from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from nats.aio.client import Client as NATS
import os, json

app = FastAPI(title="Ahla Meet Signal")
nc = NATS()

@app.on_event("startup")
async def startup():
    await nc.connect(servers=[os.getenv("NATS_URL","nats://localhost:4222")])

@app.websocket("/ws")
async def ws(ws: WebSocket):
    await ws.accept()
    try:
        hello = await ws.receive_json()
        room = hello.get("room","default")
        sub = await nc.subscribe(f"webrtc.room.{room}")
        async def pull():
            async for msg in sub.messages:
                await ws.send_text(msg.data.decode())
        import anyio
        async with anyio.create_task_group() as tg:
            tg.start_soon(pull)
            while True:
                data = await ws.receive_text()
                await nc.publish(f"webrtc.room.{room}".encode(), data.encode())
    except WebSocketDisconnect:
        pass
