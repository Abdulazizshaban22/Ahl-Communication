import os, json, numpy as np, psycopg2
from aiokafka import AIOKafkaConsumer, AIOKafkaProducer
KAFKA_BROKERS = os.getenv("KAFKA_BROKERS","kafka:9092")

def pg_conn():
    return psycopg2.connect(
        host=os.getenv("PGHOST","127.0.0.1"),
        port=int(os.getenv("PGPORT","5432")),
        dbname=os.getenv("PGDATABASE","aif"),
        user=os.getenv("PGUSER","aif"),
        password=os.getenv("PGPASSWORD",""),
    )

async def consumer(topic:str, group="aif-core"):
    c = AIOKafkaConsumer(topic, bootstrap_servers=KAFKA_BROKERS, group_id=group,
                         value_deserializer=lambda v: json.loads(v.decode("utf-8")))
    await c.start(); return c
async def producer():
    p = AIOKafkaProducer(bootstrap_servers=KAFKA_BROKERS,
                         value_serializer=lambda v: json.dumps(v).encode("utf-8"))
    await p.start(); return p

def simple_embed(text:str, dim:int=768):
    rng = np.random.default_rng(abs(hash(text)) % (2**32))
    v = rng.standard_normal(dim).astype(np.float32)
    v = v / (np.linalg.norm(v) + 1e-9)
    return v
