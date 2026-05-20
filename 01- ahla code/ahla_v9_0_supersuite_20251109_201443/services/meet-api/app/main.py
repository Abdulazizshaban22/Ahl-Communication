from fastapi import FastAPI
from pydantic import BaseModel
from starlette_exporter import PrometheusMiddleware, handle_metrics
import time, uuid

app = FastAPI(title="Ahla Meet API",version="0.1.0")
app.add_middleware(PrometheusMiddleware); app.add_route("/metrics", handle_metrics)

class Schedule(BaseModel):
    title: str
    at: float

MEETINGS = {}

@app.get("/health")
def health(): return {"ok":True}

@app.post("/meet/schedule")
def schedule(m:Schedule):
    mid = str(uuid.uuid4())
    MEETINGS[mid] = {"id": mid, "title": m.title, "at": m.at}
    return MEETINGS[mid]

@app.get("/meet/{mid}")
def get_meet(mid:str):
    return MEETINGS.get(mid, {"error":"not_found"})
