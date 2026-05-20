import os, orjson
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from state import STATE
from kafka_consumer import start_background
from time import sleep

app = FastAPI(title="Ahla Insight Gateway", version="1.0")

origins = os.getenv("GATEWAY_ALLOW_ORIGINS","*").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins, allow_credentials=True, allow_methods=["*"], allow_headers=["*"],
)

# Start Kafka consumption in background
start_background()

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/snapshot")
def snapshot():
    return STATE.snapshot()

@app.websocket("/ws")
async def ws(websocket: WebSocket):
    await websocket.accept()
    last_cnt = -1
    while True:
        snap = STATE.snapshot()
        cnt = snap["kpi"].get("cnt_asr",0) + snap["kpi"].get("cnt_emotion",0) + snap["kpi"].get("cnt_suggestions",0)
        if cnt != last_cnt:
            await websocket.send_bytes(orjson.dumps(snap))
            last_cnt = cnt
        await websocket.receive_text() if False else None  # keepalive path
        await asyncio_sleep(0.5)

# lightweight asyncio sleep without importing asyncio at top
import asyncio
async def asyncio_sleep(t): 
    await asyncio.sleep(t)
