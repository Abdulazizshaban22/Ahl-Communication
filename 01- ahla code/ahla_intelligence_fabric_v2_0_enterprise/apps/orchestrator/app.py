import os, json, asyncio
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel
from aiokafka import AIOKafkaProducer
from aws_msk_iam_sasl_signer import MSKAuthTokenProvider

AUTH_MODE = os.getenv("AUTH_MODE","iam")  # "iam" or "scram"
BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP","kafka:9092")

def get_producer_kwargs():
    if AUTH_MODE == "iam":
        return dict(
            bootstrap_servers=BOOTSTRAP,
            security_protocol="SASL_SSL",
            sasl_mechanism="OAUTHBEARER",
            sasl_oauth_token_provider=MSKAuthTokenProvider.generate_auth_token
        )
    else:
        return dict(
            bootstrap_servers=BOOTSTRAP,
            security_protocol="SASL_SSL",
            sasl_mechanism="SCRAM-SHA-512",
            sasl_plain_username=os.getenv("MSK_SCRAM_USERNAME",""),
            sasl_plain_password=os.getenv("MSK_SCRAM_PASSWORD","")
        )

app = FastAPI(title="AIF Orchestrator (Enterprise)")
TOPICS = [
    "chat.events","emotion.outputs","ai.suggestions","analyze.alerts","talk.commands",
    "meet.events","drive.events","business.events","meet.analytics","drive.audit","business.kpi"
]

producer = None

class Message(BaseModel):
    topic: str
    key: str | None = None
    value: dict

@app.on_event("startup")
async def startup():
    global producer
    producer = AIOKafkaProducer(value_serializer=lambda v: json.dumps(v).encode("utf-8"), **get_producer_kwargs())
    await producer.start()

@app.on_event("shutdown")
async def shutdown():
    if producer:
        asyncio.get_event_loop().run_until_complete(producer.stop())

@app.get("/health")
async def health(x_from_cloudfront: str | None = Header(default=None)):
    # Optional: enforce CloudFront header at app level too
    if x_from_cloudfront != "true":
        # keep relaxed for initial wiring; ALB SG already restricts to CloudFront
        pass
    return {"status":"ok","auth":AUTH_MODE}

@app.post("/event")
async def publish(msg: Message):
    assert msg.topic in TOPICS
    await producer.send_and_wait(msg.topic, msg.value, key=(msg.key or "").encode("utf-8") if msg.key else None)
    return {"ok": True}

# Convenience endpoints
@app.post("/chat/send")      async def chat_send(v:dict):     return await publish(Message(topic="chat.events",     key=v.get("user_id"), value=v))
@app.post("/meet/event")     async def meet_event(v:dict):    return await publish(Message(topic="meet.events",     key=v.get("room_id"), value=v))
@app.post("/drive/event")    async def drive_event(v:dict):   return await publish(Message(topic="drive.events",    key=v.get("file_id"), value=v))
@app.post("/business/event") async def biz_event(v:dict):     return await publish(Message(topic="business.events", key=v.get("org_id"),  value=v))
