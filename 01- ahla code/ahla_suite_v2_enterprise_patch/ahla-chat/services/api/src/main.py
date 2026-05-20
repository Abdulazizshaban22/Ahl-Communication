import asyncio, json, os, datetime as dt
from fastapi import FastAPI
from pydantic import BaseModel
from nats.aio.client import Client as NATS
from nats.js.api import StreamConfig, RetentionPolicy

app = FastAPI(title="Ahla Chat API (NATS)")

NATS_URL = os.getenv("NATS_URL","nats://localhost:4222")
STREAM = os.getenv("NATS_STREAM","CHAT")
SUBJECT_MSG = "chat.msg.v1"

nc = NATS()
js = None

@app.on_event("startup")
async def startup_event():
    global js
    await nc.connect(servers=[NATS_URL])
    js = nc.jetstream()
    # Ensure stream exists
    try:
        await js.add_stream(StreamConfig(name=STREAM, subjects=[SUBJECT_MSG], retention=RetentionPolicy.Workqueue))
    except Exception:
        pass  # already exists

class Msg(BaseModel):
    chat_id:str
    text:str
    author_id:str="me"

@app.get("/healthz")
def healthz(): return {"ok":True}

@app.post("/api/messages")
async def post_msg(m: Msg):
    payload = {
        "chat_id": m.chat_id,
        "message_id": os.urandom(8).hex(),
        "author_id": m.author_id,
        "text": m.text,
        "ts": dt.datetime.utcnow().isoformat()+"Z",
        "context": "personal"
    }
    await js.publish(SUBJECT_MSG, json.dumps(payload, ensure_ascii=False).encode("utf-8"))
    return {"ok": True, "published": True, "id": payload["message_id"]}
