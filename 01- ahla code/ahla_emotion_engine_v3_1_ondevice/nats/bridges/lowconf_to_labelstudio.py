# Bridge low-confidence queue to Label Studio tasks
import os, asyncio, json, nats, requests

NATS_URL = os.getenv("NATS_URL","nats://127.0.0.1:4222")
STREAM   = os.getenv("NATS_STREAM","AHLA_EMOTION")
SUBJECT  = os.getenv("NATS_SUBJ","ahla.emotion.lowconf")
DURABLE  = os.getenv("NATS_DURABLE","labeler")

LS_URL   = os.getenv("LABEL_STUDIO_URL","http://localhost:8080")
LS_TOKEN = os.getenv("LABEL_STUDIO_API_TOKEN","")
LS_PROJECT = int(os.getenv("LABEL_STUDIO_PROJECT_ID","1"))

def ls_headers():
    return {"Authorization": f"Token {LS_TOKEN}"}

def create_task(text, meta):
    data = {"data": {"text": text}, "meta": meta}
    r = requests.post(f"{LS_URL}/api/projects/{LS_PROJECT}/import", headers=ls_headers(), json=[data], timeout=10)
    r.raise_for_status()

async def main():
    nc = await nats.connect(NATS_URL)
    js = nc.jetstream()
    await js.add_stream(name=STREAM, subjects=[SUBJECT])
    sub = await js.pull_subscribe(subject=SUBJECT, durable=DURABLE)
    while True:
        msgs = await sub.fetch(10, timeout=5)
        for m in msgs:
            try:
                payload = json.loads(m.data.decode())
                text = payload.get("text","")
                meta = {k: v for k, v in payload.items() if k != "text"}
                if text and LS_TOKEN:
                    create_task(text, meta)
            finally:
                await m.ack()

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
