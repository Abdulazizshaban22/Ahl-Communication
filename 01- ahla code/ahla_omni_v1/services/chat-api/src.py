from fastapi import FastAPI
from pydantic import BaseModel
import asyncio, os
from datetime import datetime
import json
from nats.aio.client import Client as NATS

app = FastAPI(title="Ahla Chat API")
nc = NATS()
NATS_URL = os.getenv("NATS_URL","nats://localhost:4222")

class Msg(BaseModel):
    room: str
    user: str
    text: str

@app.on_event("startup")
async def startup():
    await nc.connect(servers=[NATS_URL])

@app.on_event("shutdown")
async def shutdown():
    if nc.is_connected:
        await nc.drain()

@app.get("/healthz")
async def healthz():
    return {"ok": True}

@app.post("/send")
async def send(m: Msg):
    payload = {"user": m.user, "text": m.text, "ts": datetime.utcnow().isoformat()+"Z"}
    await nc.publish(f"chat.room.{m.room}".encode(), bytes(json.dumps(payload), "utf-8"))
    return {"ok": True}
