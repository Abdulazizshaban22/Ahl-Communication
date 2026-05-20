import os, json, time
from confluent_kafka import Consumer, KafkaException
from aws_msk_iam_sasl_signer import MSKAuthTokenProvider

BOOTSTRAP = os.environ["MSK_BOOTSTRAP_SERVERS"]
REGION = os.getenv("AWS_REGION", "eu-central-1")

def oauth_cb(oauthbearer_config):
    tok, md, _ = MSKAuthTokenProvider.generate_auth_token(region=REGION)
    return (tok, time.time() + 900, md)

conf = {
    "bootstrap.servers": BOOTSTRAP,
    "group.id": "ahla-aif-consumers",
    "auto.offset.reset": "latest",
    "security.protocol": "SASL_SSL",
    "sasl.mechanisms": "OAUTHBEARER",
    "oauth_cb": oauth_cb
}
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
            value = json.loads(msg.value().decode("utf-8"))
            yield value
    finally:
        consumer.close()
