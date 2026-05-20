from fastapi import FastAPI, UploadFile, File, HTTPException
from pydantic import BaseModel
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from nats.aio.client import Client as NATS
import os, json
from datetime import datetime

app = FastAPI(title="Ahla Chat API v2")
NATS_URL = os.getenv("NATS_URL","nats://localhost:4222")
DATABASE_URL = os.getenv("DATABASE_URL","postgresql+psycopg://ahla:ahla@localhost:5432/ahla")

engine = create_engine(DATABASE_URL, future=True)
nc = NATS()

@app.on_event("startup")
async def on_start():
    # init DB tables (idempotent)
    with engine.begin() as conn:
        conn.execute(text("""        create table if not exists chat_rooms(
          id uuid primary key,
          org_id text not null,
          title text,
          kind text default 'direct',
          created_at timestamptz default now()
        );
        create table if not exists chat_messages(
          id bigserial primary key,
          room_id uuid,
          user_id text,
          author text,
          ts timestamptz,
          payload jsonb,
          created_at timestamptz default now()
        );
        create index if not exists chat_messages_room_ts on chat_messages(room_id, ts);
        create index if not exists chat_messages_payload_gin on chat_messages using gin(payload);
        """))
    await nc.connect(servers=[NATS_URL])

@app.on_event("shutdown")
async def on_stop():
    if nc.is_connected:
        await nc.drain()

class SendIn(BaseModel):
    room: str
    user: str
    text: str

@app.post("/send")
async def send(m: SendIn):
    payload = {"user": m.user, "text": m.text, "ts": datetime.utcnow().isoformat()+"Z"}
    subj = f"chat.room.{m.room}"
    await nc.publish(subj.encode(), json.dumps(payload).encode())
    with engine.begin() as conn:
        conn.execute(text("insert into chat_messages(room_id,user_id,author,ts,payload) values (gen_random_uuid(), :user, :user, now(), :payload)"),
                     {"user": m.user, "payload": json.dumps({"text": m.text})})
    return {"ok": True}

@app.post("/import/whatsapp")
async def import_whatsapp(file: UploadFile = File(...)):
    # Expects JSONL of records: {room_id, user_id, author, ts, payload}
    if not file.filename.endswith(".jsonl"):
        raise HTTPException(400, "Upload JSONL exported by importer")
    count = 0
    content = (await file.read()).decode("utf-8", errors="ignore")
    with engine.begin() as conn:
        for line in content.splitlines():
            if not line.strip(): continue
            rec = json.loads(line)
            ts = rec.get("ts")
            conn.execute(text(
                "insert into chat_messages(room_id,user_id,author,ts,payload) values (:room_id,:user_id,:author,:ts,:payload)"),
                {"room_id": rec.get("room_id"), "user_id": rec.get("user_id"), "author": rec.get("author"),
                 "ts": ts, "payload": json.dumps(rec.get("payload",{}))})
            count += 1
    return {"ok": True, "imported": count}

@app.get("/healthz")
async def healthz():
    return {"ok": True}
