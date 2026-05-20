import os, json
from typing import List, Optional
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
from starlette_exporter import PrometheusMiddleware, handle_metrics
from .auth import JWTVerifier

try:
    import redis
    r = redis.Redis.from_url(os.getenv("REDIS_URL","redis://redis:6379/0"), decode_responses=True)
except Exception:
    r = None

# JWT verifier (optional)
ISSUER = os.getenv("KC_URL","http://keycloak:8080") + "/realms/" + os.getenv("KC_REALM","ahla")
JWKS = ISSUER + "/protocol/openid-connect/certs"
AUD  = os.getenv("KC_CLIENT","omni-web")
verifier = JWTVerifier(issuer=ISSUER, audience=AUD, jwks_url=JWKS) if os.getenv("ENFORCE_JWT","false").lower()=="true" else None

app = FastAPI(title="Ahla Chat API", version="0.2.0")
app.add_middleware(PrometheusMiddleware)
app.add_route("/metrics", handle_metrics)

class Message(BaseModel):
    id: str
    user: str
    text: Optional[str] = None
    ts: int

def require_auth(auth: str|None):
    if verifier is None: return
    if not auth or not auth.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="missing token")
    token = auth.split(" ",1)[1]
    try:
        verifier.verify(token)
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))

@app.get("/health")
def health(): return {"ok":True}

@app.get("/messages/{room}", response_model=List[Message])
def get_messages(room:str, limit:int=50, authorization: str|None = Header(default=None)):
    require_auth(authorization)
    key = f"room:{room}:messages"
    if r: 
        return [json.loads(x) for x in r.lrange(key, -limit, -1)]
    return []

@app.post("/messages/{room}")
def add_message(room:str, msg: Message, authorization: str|None = Header(default=None)):
    require_auth(authorization)
    key = f"room:{room}:messages"
    if r:
        r.rpush(key, msg.model_dump_json())
        r.ltrim(key, -500, -1)
    return {"ok":True}

@app.post("/suggest")
def suggest(text:str):
    s = ["تم ✅","أكيد ✔️","على الرحب والسعة","أحتاج توضيح بسيط؟"]
    return {"suggestions": s}
