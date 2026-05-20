import os, json, time, base64
from typing import List, Optional, Dict, Any
from fastapi import FastAPI, Header, HTTPException, Depends
from pydantic import BaseModel
from starlette_exporter import PrometheusMiddleware, handle_metrics

REDIS_URL = os.getenv("REDIS_URL", "redis://redis:6379/0")
MEILI_URL = os.getenv("MEILI_URL", "http://meilisearch:7700")
MEILI_KEY = os.getenv("MEILI_KEY", "masterKey")
JWT_OPTIONAL = os.getenv("JWT_OPTIONAL", "true").lower() == "true"
JWT_AUDIENCE = os.getenv("JWT_AUD", None)
JWT_ISSUER = os.getenv("JWT_ISS", None)
JWT_PUBLIC_KEY = os.getenv("JWT_PUBLIC_KEY", None)

try:
    import redis
    r = redis.Redis.from_url(REDIS_URL, decode_responses=True)
    r.ping()
except Exception:
    r = None

import requests
def meili_index(doc: Dict[str, Any]):
    try:
        requests.post(f"{MEILI_URL}/indexes/messages/documents", json=[doc], headers={"X-Meili-API-Key": MEILI_KEY}, timeout=1.5)
    except Exception:
        pass

from jose import jwt, JWTError

def verify_jwt(auth: Optional[str] = Header(None)):
    if JWT_OPTIONAL and not auth:
        return {"sub":"dev-user"}
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="missing token")
    token = auth.split(" ",1)[1]
    try:
        if JWT_PUBLIC_KEY:
            payload = jwt.decode(token, JWT_PUBLIC_KEY, algorithms=["RS256"], audience=JWT_AUDIENCE, issuer=JWT_ISSUER)
        else:
            payload = jwt.get_unverified_claims(token)
        return payload
    except JWTError as e:
        raise HTTPException(status_code=401, detail=str(e))

app = FastAPI(title="Ahla Chat API", version="0.2.0")
app.add_middleware(PrometheusMiddleware)
app.add_route("/metrics", handle_metrics)

class Enc(BaseModel):
    v:int
    alg:str
    iv:str
    ct:str

class Message(BaseModel):
    id: str
    user: str
    text: Optional[str] = None
    enc: Optional[Enc] = None
    ts: int

class SuggestRequest(BaseModel):
    text: str

ROOM_KEY = lambda r: f"room:{r}:messages"

@app.get("/health")
def health():
    return {"status":"ok"}

@app.get("/messages/{room}", response_model=List[Message])
def get_messages(room: str, limit: int = 50, _claims=Depends(verify_jwt)):
    if r:
        items = r.lrange(ROOM_KEY(room), -limit, -1) or []
        return [json.loads(x) for x in items]
    return []

@app.post("/messages/{room}")
def add_message(room: str, msg: Message, _claims=Depends(verify_jwt)):
    if r:
        r.rpush(ROOM_KEY(room), msg.model_dump_json())
        r.ltrim(ROOM_KEY(room), -500, -1)
    # index plaintext only if exists
    if msg.text:
        meili_index({ "id": f"{room}:{msg.id}", "room": room, "user": msg.user, "text": msg.text, "ts": msg.ts })
    return {"ok": True}

@app.post("/suggest")
def suggest(req: SuggestRequest, _claims=Depends(verify_jwt)):
    t = req.text.strip()
    suggestions = []
    # route via emotion engine to adjust tone
    mood = "neutral"
    try:
        import requests
        x = requests.post(os.getenv("EMOTION_URL","http://emotion-engine:8010/analyze"), json={"text": t}, timeout=1.0)
        mood = x.json().get("mood","neutral")
    except Exception:
        pass
    if t.endswith("?"):
        suggestions = ["أكيد ✔️", "أحتاج توضيح بسيط؟", "يتم الآن — أعطيك خبر"]
    elif any(w in t for w in ["شكرا","شكرًا","thanks","thank"]):
        suggestions = ["العفو 🙏", "يسعدني", "على الرحب والسعة"]
    else:
        suggestions = ["تم ✅", "تمام — نتابع", "أرسلت التفاصيل الآن"]
    if mood=="negative":
        suggestions = [s + " (بتقدير)" for s in suggestions]
    return {"mood": mood, "suggestions": suggestions}
