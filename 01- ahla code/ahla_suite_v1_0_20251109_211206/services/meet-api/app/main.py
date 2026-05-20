
import json
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import PlainTextResponse
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="Ahla Meet Signaling", version="1.0.0")
MSG = Counter("ahla_meet_signaling","WS messages", [])

@app.get("/metrics")
def metrics(): return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

rooms = {}
@app.websocket("/ws")
async def ws(ws: WebSocket):
    await ws.accept()
    room = ws.query_params.get("room","room1")
    rooms.setdefault(room, set()).add(ws)
    try:
        while True:
            data = await ws.receive_text()
            MSG.inc()
            for c in list(rooms.get(room,set())):
                if c is not ws:
                    try: await c.send_text(data)
                    except: pass
    except WebSocketDisconnect:
        rooms.get(room,set()).discard(ws)
