
import os, json
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Body
from fastapi.responses import JSONResponse, PlainTextResponse
from pydantic import BaseModel
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="Ahla Chat API", version="1.2.0")
MSG = Counter("ahla_chat_messages","messages",["room"])

rooms = {}
store = {}

class Message(BaseModel):
    id:str; user:str; ts:int
    text:str|None=None
    c:dict|None=None

@app.get("/health")
def health(): return {"ok":True}

@app.get("/messages/{room}")
def messages(room:str):
    return store.get(room, [])

@app.post("/messages/{room}")
def add(room:str, msg:Message):
    arr = store.setdefault(room, [])
    arr.append(msg.model_dump())
    MSG.labels(room=room).inc()
    return {"ok":True}

@app.get("/metrics")
def metrics(): return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.websocket("/ws")
async def ws(ws: WebSocket):
    await ws.accept()
    room = ws.query_params.get("room","personal")
    rooms.setdefault(room,set()).add(ws)
    try:
        while True:
            data = await ws.receive_text()
            for c in list(rooms.get(room,set())):
                try: await c.send_text(data)
                except: pass
    except WebSocketDisconnect:
        rooms.get(room,set()).discard(ws)
