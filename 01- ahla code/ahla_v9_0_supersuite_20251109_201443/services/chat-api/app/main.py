import os, json, time
from typing import List, Optional
from fastapi import FastAPI
from pydantic import BaseModel
from starlette_exporter import PrometheusMiddleware, handle_metrics

try:
    import redis
    r = redis.Redis.from_url(os.getenv("REDIS_URL","redis://redis:6379/0"), decode_responses=True)
except Exception:
    r = None

app = FastAPI(title="Ahla Chat API", version="0.1.0")
app.add_middleware(PrometheusMiddleware)
app.add_route("/metrics", handle_metrics)

class Message(BaseModel):
    id: str
    user: str
    text: Optional[str] = None
    ts: int

@app.get("/health")
def health(): return {"ok":True}

@app.get("/messages/{room}", response_model=List[Message])
def get_messages(room:str, limit:int=50):
    key = f"room:{room}:messages"
    if r: 
        return [json.loads(x) for x in r.lrange(key, -limit, -1)]
    return []

@app.post("/messages/{room}")
def add_message(room:str, msg: Message):
    key = f"room:{room}:messages"
    if r:
        r.rpush(key, msg.model_dump_json())
        r.ltrim(key, -500, -1)
    return {"ok":True}

@app.post("/suggest")
def suggest(text:str):
    s = ["تم ✅","أكيد ✔️","على الرحب والسعة","أحتاج توضيح بسيط؟"]
    return {"suggestions": s}
