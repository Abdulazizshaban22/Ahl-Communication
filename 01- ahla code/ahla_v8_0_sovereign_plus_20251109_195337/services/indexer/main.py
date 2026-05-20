import os, json, time, requests, redis

REDIS_URL = os.getenv("REDIS_URL","redis://redis:6379/0")
MEILI_URL = os.getenv("MEILI_URL","http://meilisearch:7700")
MEILI_KEY = os.getenv("MEILI_KEY","masterKey")

r = redis.Redis.from_url(REDIS_URL, decode_responses=True)

def iterate_rooms():
    for k in r.scan_iter("room:*:messages"):
        yield k

def backfill():
    for k in iterate_rooms():
        room = k.split(":")[1]
        msgs = [json.loads(x) for x in r.lrange(k, 0, -1)]
        docs = []
        for m in msgs:
            if m.get("text"):
                docs.append({ "id": f"{room}:{m['id']}", "room": room, "user": m["user"], "text": m["text"], "ts": m["ts"] })
        if docs:
            try:
                requests.post(f"{MEILI_URL}/indexes/messages/documents", json=docs, headers={"X-Meili-API-Key": MEILI_KEY}, timeout=3.0)
                print("Indexed", len(docs), "docs for", room)
            except Exception as e:
                print("index error:", e)

if __name__ == "__main__":
    backfill()
