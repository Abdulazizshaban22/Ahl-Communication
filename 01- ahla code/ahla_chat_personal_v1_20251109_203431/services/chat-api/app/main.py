import os, json
from typing import List, Optional
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
from pydantic import BaseModel

try:
    import redis
    r = redis.Redis.from_url(os.getenv("REDIS_URL","redis://redis:6379/0"), decode_responses=True)
except Exception:
    r = None

STORE = os.getenv("ATTACH_STORE","/data")
os.makedirs(STORE, exist_ok=True)

app = FastAPI(title="Ahla Chat Personal API", version="1.0.0")

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

@app.get("/messages/{room}", response_model=List[Message])
def get_messages(room:str, limit:int=200):
    key = f"room:{room}:messages"
    if r:
        data = [json.loads(x) for x in r.lrange(key, -limit, -1)]
        data.sort(key=lambda m: m.get('ts',0))
        return data
    return []

@app.post("/messages/{room}")
def add_message(room:str, msg: Message):
    key = f"room:{room}:messages"
    if r:
        r.rpush(key, msg.model_dump_json())
        r.ltrim(key, -2000, -1)
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