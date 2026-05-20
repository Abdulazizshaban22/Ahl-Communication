import os, json, numpy as np, psycopg2
from aiokafka import AIOKafkaConsumer, AIOKafkaProducer
from aws_msk_iam_sasl_signer import MSKAuthTokenProvider

AUTH_MODE = os.getenv("AUTH_MODE","iam")
BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP","kafka:9092")

def kafka_consumer(topic, group="aif-core"):
    kwargs = dict(bootstrap_servers=BOOTSTRAP, group_id=group, value_deserializer=lambda v: json.loads(v.decode("utf-8")))
    if AUTH_MODE == "iam":
        kwargs.update(dict(security_protocol="SASL_SSL", sasl_mechanism="OAUTHBEARER", sasl_oauth_token_provider=MSKAuthTokenProvider.generate_auth_token))
    else:
        kwargs.update(dict(security_protocol="SASL_SSL", sasl_mechanism="SCRAM-SHA-512",
            sasl_plain_username=os.getenv("MSK_SCRAM_USERNAME",""), sasl_plain_password=os.getenv("MSK_SCRAM_PASSWORD","")))
    return AIOKafkaConsumer(topic, **kwargs)

def kafka_producer():
    kwargs = dict(bootstrap_servers=BOOTSTRAP, value_serializer=lambda v: json.dumps(v).encode("utf-8"))
    if AUTH_MODE == "iam":
        kwargs.update(dict(security_protocol="SASL_SSL", sasl_mechanism="OAUTHBEARER", sasl_oauth_token_provider=MSKAuthTokenProvider.generate_auth_token))
    else:
        kwargs.update(dict(security_protocol="SASL_SSL", sasl_mechanism="SCRAM-SHA-512",
            sasl_plain_username=os.getenv("MSK_SCRAM_USERNAME",""), sasl_plain_password=os.getenv("MSK_SCRAM_PASSWORD","")))
    return AIOKafkaProducer(**kwargs)

def pg_conn():
    return psycopg2.connect(
        host=os.getenv("PGHOST","127.0.0.1"),
        port=int(os.getenv("PGPORT","5432")),
        dbname=os.getenv("PGDATABASE","aif"),
        user=os.getenv("PGUSER","aif_user"),
        password=os.getenv("PGPASSWORD",""),
    )

def simple_embed(text:str, dim:int=768):
    rng = np.random.default_rng(abs(hash(text)) % (2**32))
    v = rng.standard_normal(dim).astype(np.float32)
    v = v / (np.linalg.norm(v) + 1e-9)
    return v
