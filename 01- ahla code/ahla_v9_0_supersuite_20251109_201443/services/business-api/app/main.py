from fastapi import FastAPI
from pydantic import BaseModel
from starlette_exporter import PrometheusMiddleware, handle_metrics
import uuid, time
app = FastAPI(title="Ahla Business API",version="0.1.0")
app.add_middleware(PrometheusMiddleware); app.add_route("/metrics", handle_metrics)

class Task(BaseModel):
    title: str
    due: float | None = None
    assignee: str | None = None

TASKS = {}

@app.get("/health")
def health(): return {"ok":True}

@app.post("/tasks")
def create_task(t:Task):
    tid = str(uuid.uuid4())
    TASKS[tid] = {"id":tid, **t.model_dump()}
    return TASKS[tid]

@app.get("/tasks")
def list_tasks(): return list(TASKS.values())
