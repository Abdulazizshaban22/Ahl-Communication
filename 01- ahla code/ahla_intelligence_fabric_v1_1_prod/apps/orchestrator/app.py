from fastapi import FastAPI
from pydantic import BaseModel
import os, json, asyncio
from aiokafka import AIOKafkaProducer

app = FastAPI(title="AIF Orchestrator (Prod)")
TOPICS = ["chat.events","emotion.outputs","ai.suggestions","analyze.alerts","talk.commands"]
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
