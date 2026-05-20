import os, json, time
import requests, redis

MEILI = os.getenv("MEILI_URL","http://meilisearch:7700")
MEILI_KEY = os.getenv("MEILI_MASTER_KEY","masterKey")
R = redis.Redis.from_url(os.getenv("REDIS_URL","redis://redis:6379/0"), decode_responses=True)

def index_room(room):
    key = f"room:{room}:messages"
    msgs = [json.loads(x) for x in R.lrange(key, 0, -1)]
    if not msgs: return
    idx = "chat_"+room.replace(":","_")
    r = requests.put(f"{MEILI}/indexes/{idx}", headers={"Authorization": f"Bearer {MEILI_KEY}"})
    r = requests.post(f"{MEILI}/indexes/{idx}/documents", headers={"Authorization": f"Bearer {MEILI_KEY}"}, json=msgs)
    print("indexed", idx, len(msgs))

if __name__=="__main__":
    while True:
        # naive example: index a fixed set of rooms
        for room in ["general","support"]:
            index_room(room)
        time.sleep(10)
