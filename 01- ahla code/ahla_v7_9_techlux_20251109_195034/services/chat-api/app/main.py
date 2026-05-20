import os
from typing import List, Dict, Any
from fastapi import FastAPI
from pydantic import BaseModel
from starlette_exporter import PrometheusMiddleware, handle_metrics

REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")
ROOM_KEY = lambda r: f"room:{r}:messages"

try:
    import redis
    r = redis.Redis.from_url(REDIS_URL, decode_responses=True)
    r.ping()
except Exception:
    r = None

app = FastAPI(title="Ahla Chat API", version="0.1.0")
app.add_middleware(PrometheusMiddleware)
app.add_route("/metrics", handle_metrics)

class Message(BaseModel):
    id: str
    user: str
    text: str
    ts: int

class SuggestRequest(BaseModel):
    text: str

@app.get("/health")
def health():
    return {"status":"ok"}

@app.get("/messages/{room}", response_model=List[Message])
def get_messages(room: str, limit: int = 50):
    if r:
        items = r.lrange(ROOM_KEY(room), -limit, -1) or []
        import json
        return [json.loads(x) for x in items]
    return []

@app.post("/messages/{room}")
def add_message(room: str, msg: Message):
    if r:
        import json
        r.rpush(ROOM_KEY(room), json.dumps(msg.dict()))
        r.ltrim(ROOM_KEY(room), -500, -1)
    return {"ok": True}

@app.post("/suggest")
def suggest(req: SuggestRequest):
    t = req.text.strip()
    suggestions = []
    if t.endswith("?"):
        suggestions = ["أكيد ✔️", "أحتاج مزيد من التوضيح؟", "يتم الآن — أعطيك خبر"]
    elif any(w in t for w in ["شكرا","شكرًا","thanks","thank"]):
        suggestions = ["العفو 🙏", "يسعدني", "على الرحب والسعة"]
    else:
        suggestions = ["تم ✅", "تمام — نتابع", "رجّعت لك التفاصيل"]
    return {"suggestions": suggestions}
