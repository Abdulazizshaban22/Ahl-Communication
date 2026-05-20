import os, json, time, threading
from confluent_kafka import Consumer, KafkaException
from aws_msk_iam_sasl_signer import MSKAuthTokenProvider
from state import STATE

REGION = os.getenv("AWS_REGION","me-central-1")
BOOTSTRAP = os.getenv("KAFKA_BROKERS","redpanda:9092")
SEC = os.getenv("KAFKA_SECURITY_PROTOCOL","PLAINTEXT").upper()
MECH = os.getenv("KAFKA_SASL_MECHANISM","none").lower()

TOPIC_ASR = os.getenv("TOPIC_ASR","aif.asr")
TOPIC_EMO = os.getenv("TOPIC_EMOTION","aif.emotion")
TOPIC_SUG = os.getenv("TOPIC_SUGGESTIONS","aif.suggestions")

def oauth_cb(oauthbearer_config):
    tok, md, _ = MSKAuthTokenProvider.generate_auth_token(region=REGION)
    return (tok, time.time() + 900, md)

def _make_consumer(group_id: str):
    conf = {
        "bootstrap.servers": BOOTSTRAP,
        "group.id": group_id,
        "auto.offset.reset": "latest",
    }
    if MECH in ("oauthbearer","aws_msk_iam"):
        conf.update({
            "security.protocol": "SASL_SSL",
            "sasl.mechanisms": "OAUTHBEARER",
            "oauth_cb": oauth_cb,
        })
    return Consumer(conf)

def _loop(topic: str, bucket: str):
    c = _make_consumer(f"ahla-insight-{bucket}")
    c.subscribe([topic])
    try:
        while True:
            msg = c.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                raise KafkaException(msg.error())
            try:
                data = json.loads(msg.value().decode("utf-8"))
            except Exception:
                data = {"raw": msg.value().decode("utf-8","ignore")}
            getattr(STATE, bucket).append(data)
            # light KPI update
            STATE.kpi[f"cnt_{bucket}"] += 1
    finally:
        c.close()

def start_background():
    for topic, bucket in [(TOPIC_ASR,"asr"), (TOPIC_EMO,"emotion"), (TOPIC_SUG,"suggestions")]:
        t = threading.Thread(target=_loop, args=(topic, bucket), daemon=True)
        t.start()
