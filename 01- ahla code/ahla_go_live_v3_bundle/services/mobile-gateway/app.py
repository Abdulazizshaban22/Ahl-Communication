import os, json, asyncio
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import nats

NATS_URL = os.getenv("NATS_URL", "nats://127.0.0.1:4222")
app = FastAPI()

@app.websocket("/ws/chat")
async def ws_chat(ws: WebSocket):
    await ws.accept()
    nc = await nats.connect(servers=[NATS_URL])
    sub = None
    try:
        hello = await ws.receive_text()
        hello = json.loads(hello) if hello else {}
        room = hello.get("room", "general")
        subj = f"chat.room.{room}"
        sub = await nc.subscribe(subj)
        async def pump():
            async for m in sub.messages:
                await ws.send_text(m.data.decode())
        asyncio.create_task(pump())
        while True:
            msg = await ws.receive_text()
            await nc.publish(subj, msg.encode())
    except WebSocketDisconnect:
        pass
    finally:
        try:
            if sub: await sub.drain()
            await nc.drain()
        except Exception:
            pass
