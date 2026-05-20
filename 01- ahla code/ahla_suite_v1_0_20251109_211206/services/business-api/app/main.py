
import time, uuid
from fastapi import FastAPI, Body
from fastapi.responses import PlainTextResponse
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="Ahla Business API", version="1.0.0")
TASKS = []
REQ = Counter("ahla_business_reqs","requests", [])

@app.get("/metrics")
def metrics(): return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/tasks")
def tasks():
    return TASKS

@app.post("/tasks")
def add_task(payload: dict = Body(...)):
    t = {"id": str(uuid.uuid4()), "title": payload.get("title",""), "status": "open", "ts": int(time.time()*1000)}
    TASKS.append(t)
    REQ.inc()
    return {"ok": True, "task": t}
