
from fastapi import FastAPI
from pydantic import BaseModel
import os, json
from typing import Optional

# Kafka client (supports MSK IAM via oauth token)
KAFKA_BROKERS = os.getenv("MSK_BOOTSTRAP", os.getenv("KAFKA_BROKERS","redpanda:9092")).split(",")
MECH = os.getenv("KAFKA_SASL_MECHANISM","none").lower()
SEC = os.getenv("KAFKA_SECURITY_PROTOCOL","PLAINTEXT")

use_iam = MECH in ("oauthbearer","aws_msk_iam")

producer = None

def get_producer():
    global producer
    if producer is not None:
        return producer
    from kafka import KafkaProducer
    if use_iam:
        from aws_msk_iam_sasl_signer import MSKAuthTokenProvider
        class TokenProvider:
            def token(self):
                # returns OAUTHBEARER token for IAM
                return MSKAuthTokenProvider.generate_auth_token(os.getenv("AWS_REGION","me-central-1")).token
        producer = KafkaProducer(
            bootstrap_servers=KAFKA_BROKERS,
            security_protocol="SASL_SSL",
            sasl_mechanism="OAUTHBEARER",
            sasl_oauth_token_provider=TokenProvider(),
            value_serializer=lambda v: json.dumps(v).encode("utf-8"),
        )
    else:
        producer = KafkaProducer(
            bootstrap_servers=KAFKA_BROKERS,
            value_serializer=lambda v: json.dumps(v).encode("utf-8"),
        )
    return producer

app = FastAPI(title="Ahla AI Orchestrator", version="1.0")

class SuggestIn(BaseModel):
    user_id: str
    text: str
    context: Optional[dict] = None

@app.post("/suggest/reply")
def suggest(inp: SuggestIn):
    # Publish to bus for downstream consumers (chat UI, moderation)
    p = get_producer()
    payload = {"type":"suggestion","user_id":inp.user_id,"text":inp.text,"context":inp.context or {}}
    p.send("ahla.suggestions", payload)
    p.flush(3)
    return {"ok": True, "published": payload}

class ModerateIn(BaseModel):
    chat_id: str
    message_id: str
    severity_threshold: float = 0.6

@app.post("/moderate")
def moderate(inp: ModerateIn):
    # wireframe stub: downstream moderation service can act on it
    p = get_producer()
    p.send("ahla.moderation", inp.model_dump())
    p.flush(3)
    return {"ok": True}

@app.get("/health")
def health():
    return {"ok": True, "kafka": True}
