
import os, json
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.responses import JSONResponse, PlainTextResponse
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="Ahla Meet Signaling", version="1.1.0")
MSG = Counter("ahla_meet_signaling","WS messages", [])

@app.get("/metrics")
def metrics(): return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/ice")
def ice():
    stun = os.getenv("STUN_URL","stun:stun.l.google.com:19302")
    turn = os.getenv("TURN_URL","")
    user = os.getenv("TURN_USER","")
    pwd  = os.getenv("TURN_PASS","")
    servers = [{"urls": [stun]}]
    if turn:
        servers.append({"urls":[turn], "username": user, "credential": pwd})
    return JSONResponse({ "iceServers": servers })

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
