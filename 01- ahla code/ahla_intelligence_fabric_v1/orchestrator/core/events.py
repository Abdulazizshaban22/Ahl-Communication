import json
from aiokafka import AIOKafkaProducer
from kafka.admin import NewTopic
from kafka import KafkaAdminClient
from .config import KAFKA_BROKERS

async def get_producer():
    p = AIOKafkaProducer(bootstrap_servers=KAFKA_BROKERS,
                         value_serializer=lambda v: json.dumps(v).encode("utf-8"))
    await p.start()
    return p

async def ensure_topics(topics):
    admin = KafkaAdminClient(bootstrap_servers=KAFKA_BROKERS)
    existing = set(admin.list_topics())
    to_create = [NewTopic(name=t, num_partitions=1, replication_factor=1) for t in topics if t not in existing]
    if to_create:
        try:
            admin.create_topics(new_topics=to_create)
        except Exception:
            pass
    admin.close()
