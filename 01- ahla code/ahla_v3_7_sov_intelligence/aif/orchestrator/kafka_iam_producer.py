# Requires: confluent-kafka, aws-msk-iam-sasl-signer-python
import os, socket, json, time
from confluent_kafka import Producer
from aws_msk_iam_sasl_signer import MSKAuthTokenProvider

BOOTSTRAP = os.environ["MSK_BOOTSTRAP_SERVERS"]
REGION = os.getenv("AWS_REGION", "eu-central-1")

def oauth_cb(oauthbearer_config):
    tok, md, _ = MSKAuthTokenProvider.generate_auth_token(region=REGION)
    return (tok, time.time() + 900, md)

conf = {
    "bootstrap.servers": BOOTSTRAP,
    "client.id": socket.gethostname(),
    "security.protocol": "SASL_SSL",
    "sasl.mechanisms": "OAUTHBEARER",
    "oauth_cb": oauth_cb
}

producer = Producer(conf)

def send(topic, value: dict):
    producer.produce(topic, json.dumps(value).encode("utf-8"))
    producer.flush()
