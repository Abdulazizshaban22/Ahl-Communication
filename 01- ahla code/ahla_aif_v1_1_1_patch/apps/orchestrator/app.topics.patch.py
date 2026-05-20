from fastapi import FastAPI
from pydantic import BaseModel
import os, json, asyncio
from aiokafka import AIOKafkaProducer

app = FastAPI(title="AIF Orchestrator (Prod, Extended Topics)")
TOPICS = [
  "chat.events","emotion.outputs","ai.suggestions","analyze.alerts","talk.commands",
  "meet.events","drive.events","business.events",
  "meet.analytics","drive.audit","business.kpi"
]
BOOTSTRAP = os.getenv("KAFKA_BROKERS","kafka:9092")
producer = None

class Message(BaseModel):
  topic: str
  key: str | None = None
  value: dict

@app.on_event("startup")
async def startup():
  global producer
  producer = AIOKafkaProducer(bootstrap_servers=BOOTSTRAP,
      value_serializer=lambda v: json.dumps(v).encode("utf-8"))
  await producer.start()

@app.on_event("shutdown")
async def shutdown():
  if producer:
    asyncio.get_event_loop().run_until_complete(producer.stop())

@app.get("/health")
async def health(): return {"status":"ok"}

@app.post("/event")
async def publish(msg: Message):
  assert msg.topic in TOPICS
  await producer.send_and_wait(msg.topic, msg.value, key=(msg.key or "").encode("utf-8") if msg.key else None)
  return {"ok": True}

# Convenience endpoints for apps
@app.post("/chat/send")     async def chat_send(v:dict):     return await publish(Message(topic="chat.events",     key=v.get("user_id"), value=v))
@app.post("/meet/event")    async def meet_event(v:dict):    return await publish(Message(topic="meet.events",     key=v.get("room_id"), value=v))
@app.post("/drive/event")   async def drive_event(v:dict):   return await publish(Message(topic="drive.events",    key=v.get("file_id"), value=v))
@app.post("/business/event")async def biz_event(v:dict):     return await publish(Message(topic="business.events", key=v.get("org_id"),  value=v))
