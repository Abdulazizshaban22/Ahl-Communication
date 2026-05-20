import os, json, time
from confluent_kafka import Consumer, KafkaException
from aws_msk_iam_sasl_signer import MSKAuthTokenProvider

BOOTSTRAP = os.environ.get("MSK_BOOTSTRAP_SERVERS", os.environ.get("KAFKA_BROKERS","redpanda:9092"))
REGION = os.getenv("AWS_REGION","me-central-1")
SEC = os.getenv("KAFKA_SECURITY_PROTOCOL","PLAINTEXT")
MECH = os.getenv("KAFKA_SASL_MECHANISM","none").lower()

def oauth_cb(oauthbearer_config):
    tok, md, _ = MSKAuthTokenProvider.generate_auth_token(region=REGION)
    return (tok, time.time() + 900, md)

conf = {
    "bootstrap.servers": BOOTSTRAP,
    "group.id": "ahla-aif-consumers",
    "auto.offset.reset": "latest"
}
if MECH in ("oauthbearer","aws_msk_iam"):
    conf.update({
        "security.protocol": "SASL_SSL",
        "sasl.mechanisms": "OAUTHBEARER",
        "oauth_cb": oauth_cb
    })

consumer = Consumer(conf)

def run(topic):
    consumer.subscribe([topic])
    try:
        while True:
            msg = consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                raise KafkaException(msg.error())
            yield json.loads(msg.value().decode("utf-8"))
    finally:
        consumer.close()

if __name__ == "__main__":
    for rec in run("aif.suggestions"):
        print(">>", rec)
