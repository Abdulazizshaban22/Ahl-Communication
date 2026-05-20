import os, json, time
from typing import List, Optional
from fastapi import FastAPI, UploadFile, File, Body
from fastapi.responses import FileResponse
from pydantic import BaseModel

try:
    import redis
    r = redis.Redis.from_url(os.getenv("REDIS_URL","redis://redis:6379/0"), decode_responses=True)
except Exception:
    r = None

STORE = os.getenv("ATTACH_STORE","/data")
os.makedirs(STORE, exist_ok=True)

app = FastAPI(title="Ahla Chat API v3", version="3.0.0")

class Attachment(BaseModel):
    name: str
    url: str

class Message(BaseModel):
    id: str
    user: str
    text: Optional[str] = None
    cipher: Optional[str] = None
    nonce: Optional[str] = None
    attachments: Optional[list[Attachment]] = None
    ts: int

@app.get("/health")
def health(): return {"ok":True}

def get_ttl(room:str)->int:
    if not r: return 0
    v = r.get(f"room:{room}:ttl")
    try: return int(v or 0)
    except: return 0

@app.get("/ttl/{room}")
def ttl_get(room:str): return {"ttl": get_ttl(room)}

@app.post("/ttl/{room}")
def ttl_set(room:str, payload: dict = Body(...)):
    ttl = int(payload.get("ttl",0))
    if r: r.set(f"room:{room}:ttl", ttl)
    return {"ok": True, "ttl": ttl}

@app.get("/messages/{room}", response_model=List[Message])
def get_messages(room:str, limit:int=500):
    key = f"room:{room}:messages"
    ttl = get_ttl(room)
    now = int(time.time()*1000)
    if r:
        data = [json.loads(x) for x in r.lrange(key, -limit, -1)]
        if ttl>0:
            data = [m for m in data if (now - m.get('ts',0)) <= ttl*1000]
        data.sort(key=lambda m: m.get('ts',0))
        return data
    return []

@app.post("/messages/{room}")
def add_message(room:str, msg: Message):
    key = f"room:{room}:messages"
    if r:
        r.rpush(key, msg.model_dump_json())
        r.ltrim(key, -5000, -1)
    return {"ok":True}

@app.post("/attachments/{room}")
async def upload(room:str, file: UploadFile = File(...)):
    dest = os.path.join(STORE, file.filename)
    with open(dest, "wb") as f:
        f.write(await file.read())
    return {"ok":True, "url": f"/files/{file.filename}"}

@app.get("/files/{name}")
def files(name:str):
    path = os.path.join(STORE, name)
    return FileResponse(path)

# --- Tone simple ---
@app.post("/tone")
def tone(payload: dict = Body(...)):
    text = payload.get('text','')
    score = 0
    score += text.count('!')*2
    score += sum(1 for c in text if c.isupper())
    score -= text.count('😊') + text.count('❤️')
    level = 'calm'
    if score > 20: level='intense'
    elif score > 8: level='raised'
    return {"score": score, "level": level}