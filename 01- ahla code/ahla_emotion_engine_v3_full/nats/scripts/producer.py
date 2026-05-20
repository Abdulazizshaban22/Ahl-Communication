import asyncio, nats, json, os
NATS_URL = os.getenv("NATS_URL","nats://127.0.0.1:4222")
SUBJECT   = os.getenv("NATS_SUBJ","ahla.emotion.lowconf")

async def main():
    nc = await nats.connect(NATS_URL)
    # simple send demo
    msg = {"hello":"world","ts":None}
    await nc.publish(SUBJECT, json.dumps(msg).encode())
    await nc.drain()

if __name__ == "__main__":
    asyncio.run(main())
