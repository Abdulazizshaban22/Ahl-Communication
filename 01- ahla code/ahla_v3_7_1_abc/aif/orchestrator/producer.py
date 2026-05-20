import os, json, time, socket
from confluent_kafka import Producer
from aws_msk_iam_sasl_signer import MSKAuthTokenProvider

BOOTSTRAP = os.environ.get("MSK_BOOTSTRAP_SERVERS", os.environ.get("KAFKA_BROKERS","redpanda:9092"))
REGION = os.getenv("AWS_REGION","me-central-1")
SEC = os.getenv("KAFKA_SECURITY_PROTOCOL","PLAINTEXT")
MECH = os.getenv("KAFKA_SASL_MECHANISM","none").lower()

def oauth_cb(oauthbearer_config):
    tok, md, _ = MSKAuthTokenProvider.generate_auth_token(region=REGION)
    return (tok, time.time() + 900, md)

conf = {"bootstrap.servers": BOOTSTRAP, "client.id": socket.gethostname()}
if MECH in ("oauthbearer","aws_msk_iam"):
    conf.update({
        "security.protocol": "SASL_SSL",
        "sasl.mechanisms": "OAUTHBEARER",
        "oauth_cb": oauth_cb
    })

producer = Producer(conf)

def send(topic, value: dict):
    producer.produce(topic, json.dumps(value).encode("utf-8"))
    producer.flush()

if __name__ == "__main__":
    send("aif.suggestions", {"msg":"hello from producer"})
