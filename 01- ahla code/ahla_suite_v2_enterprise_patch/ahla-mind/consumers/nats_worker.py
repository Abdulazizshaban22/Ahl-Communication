import asyncio, json, os
from nats.aio.client import Client as NATS
from nats.js.api import ConsumerConfig
from nats.js.errors import NotFoundError

NATS_URL = os.getenv("NATS_URL","nats://localhost:4222")
STREAM = os.getenv("NATS_STREAM","CHAT")
SUBJECT_MSG = "chat.msg.v1"
SUBJECT_INSIGHT = "mind.insight.v1"
DURABLE = os.getenv("NATS_DURABLE","mind-worker")

async def run():
    nc = NATS(); await nc.connect(servers=[NATS_URL])
    js = nc.jetstream()
    # Ensure consumer
    try:
        await js.consumer_info(STREAM, DURABLE)
    except NotFoundError:
        await js.add_consumer(STREAM, ConsumerConfig(durable_name=DURABLE, ack_policy="explicit"))
    sub = await js.pull_subscribe(subject=SUBJECT_MSG, durable=DURABLE, stream=STREAM)
    while True:
        msgs = await sub.fetch(10, timeout=1.0)
        for msg in msgs:
            try:
                data = json.loads(msg.data.decode("utf-8"))
                txt = (data.get("text") or "").lower()
                sug = []
                if any(w in txt for w in ["زعلان","غاضب","سيء","أكره"]): sug.append("🕊️ خذوا استراحة قصيرة؟")
                if any(w in txt for w in ["شكرا","حلو","جميل","أحب"]): sug.append("🌟 أرسل تقدير/شكر؟")
                insight = {"chat_id": data["chat_id"], "message_id": data["message_id"], "suggestions": sug, "flags": []}
                await js.publish(SUBJECT_INSIGHT, json.dumps(insight, ensure_ascii=False).encode("utf-8"))
            finally:
                await msg.ack()
if __name__ == "__main__":
    asyncio.run(run())
