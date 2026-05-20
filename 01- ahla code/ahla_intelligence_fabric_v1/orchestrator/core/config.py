import os
KAFKA_BROKERS = os.getenv("KAFKA_BROKERS","kafka:9092")
GROUP = os.getenv("KAFKA_GROUP","aif-core")
