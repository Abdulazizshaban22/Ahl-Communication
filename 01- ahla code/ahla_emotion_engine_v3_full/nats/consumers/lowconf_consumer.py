import asyncio, nats, os
STREAM   = os.getenv("NATS_STREAM","AHLA_EMOTION")
SUBJECT  = os.getenv("NATS_SUBJ","ahla.emotion.lowconf")
DURABLE  = os.getenv("NATS_DURABLE","labeler")
URL      = os.getenv("NATS_URL","nats://127.0.0.1:4222")

async def main():
    nc = await nats.connect(URL)
    js = nc.jetstream()
    # ensure stream
    await js.add_stream(name=STREAM, subjects=[SUBJECT])
    # create a durable pull consumer
    sub = await js.pull_subscribe(subject=SUBJECT, durable=DURABLE)
    while True:
        msgs = await sub.fetch(10, timeout=5)
        for m in msgs:
            print("got", m.subject, m.data.decode())
            await m.ack()
    await nc.drain()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
