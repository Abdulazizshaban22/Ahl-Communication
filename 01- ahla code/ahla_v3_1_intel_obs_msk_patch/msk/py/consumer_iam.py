# Example: aiokafka consumer with MSK IAM (SASL OAUTHBEARER).
# Requires 'aws-msk-iam-sasl-signer-python' and aiokafka.
import asyncio, os
from aiokafka import AIOKafkaConsumer
from aws_msk_iam_sasl_signer import MSKAuthBearer

BOOTSTRAP = os.getenv("MSK_BOOTSTRAP", "b-1.example.aws:9098")
TOPIC = os.getenv("TOPIC", "ahla.events")

async def main():
    auth = MSKAuthBearer()  # obtains signed token using your IAM creds
    consumer = AIOKafkaConsumer(
        TOPIC,
        bootstrap_servers=BOOTSTRAP,
        security_protocol="SASL_SSL",
        sasl_mechanism="OAUTHBEARER",
        sasl_oauth_token_provider=auth
    )
    await consumer.start()
    try:
        async for msg in consumer:
            print("event:", msg.topic, msg.value)
    finally:
        await consumer.stop()

if __name__ == "__main__":
    asyncio.run(main())
