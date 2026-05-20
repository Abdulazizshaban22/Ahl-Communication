
import os, json, time
from typing import Optional
from fastapi import FastAPI, UploadFile, File, WebSocket, WebSocketDisconnect, Body
from fastapi.responses import FileResponse, PlainTextResponse
from pydantic import BaseModel
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

try:
    import redis
    r = redis.Redis.from_url(os.getenv("REDIS_URL","redis://redis:6379/0"), decode_responses=True)
except Exception:
    r = None

STORE = os.getenv("ATTACH_STORE","/data")
os.makedirs(STORE, exist_ok=True)

app = FastAPI(title="Ahla Chat API", version="1.0.0")

MSG_COUNTER = Counter("ahla_messages_total","Total messages", ["room"])

class Message(BaseModel):
    id:str; user:str; ts:int
    text: Optional[str] = None

@app.get("/metrics")
def metrics(): return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/health")
def health(): return {"ok":True}

@app.get("/messages/{room}")
def list_messages(room:str, limit:int=500):
    key=f"room:{room}:messages"
    if r: 
        data=[json.loads(x) for x in r.lrange(key, -limit, -1)]
        data.sort(key=lambda m: m.get('ts',0))
        return data
    return []

@app.post("/messages/{room}")
def add_message(room:str, msg: Message):
    key=f"room:{room}:messages"
    if r:
        r.rpush(key, msg.model_dump_json()); r.ltrim(key, -5000, -1)
    MSG_COUNTER.labels(room=room).inc()
    return {"ok":True}

# Simple file store for demo
@app.post("/attachments/{room}")
async def upload(room:str, file: UploadFile = File(...)):
    dest=os.path.join(STORE, file.filename)
    with open(dest,"wb") as f: f.write(await file.read())
    return {"ok":True, "url": f"/files/{file.filename}"}

@app.get("/files/{name}")
def files(name:str): return FileResponse(os.path.join(STORE,name))

# WS hub (shared with meet-web URL scheme)
clients = {}
@app.websocket("/ws")
async def ws(ws: WebSocket):
    await ws.accept()
    room = ws.query_params.get("room","personal")
    clients.setdefault(room, set()).add(ws)
    try:
        while True:
            data = await ws.receive_text()
            for c in list(clients.get(room, set())):
                try:
                    await c.send_text(data)
                except Exception: pass
    except WebSocketDisconnect:
        clients.get(room,set()).discard(ws)
