from fastapi import FastAPI
from pydantic import BaseModel
from core.events import get_producer, ensure_topics

TOPICS = ["chat.events","emotion.outputs","ai.suggestions","analyze.alerts","talk.commands"]
app = FastAPI(title="Ahla Intelligence Fabric — Orchestrator")

class Message(BaseModel):
    topic: str
    key: str | None = None
    value: dict

@app.on_event("startup")
async def startup():
    await ensure_topics(TOPICS)
    app.state.producer = await get_producer()

@app.on_event("shutdown")
async def shutdown():
    if hasattr(app.state, "producer"):
        await app.state.producer.stop()

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/event")
async def publish(msg: Message):
    assert msg.topic in TOPICS, f"unknown topic {msg.topic}"
    await app.state.producer.send_and_wait(msg.topic, msg.value, key=msg.key)
    return {"ok": True}
