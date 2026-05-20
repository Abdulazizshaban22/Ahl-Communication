from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime
import os

app = FastAPI(title="Ahla Notes API")

class NoteMeta(BaseModel):
    id: str
    title: str
    updatedAt: datetime

DB_URL = os.getenv("DATABASE_URL","postgresql://app_user:app_pass@localhost:5432/ahla")

# demo in-memory
NOTES = {}

@app.get("/healthz")
def h(): return {"ok": True}

@app.get("/notes")
def list_notes(): return list(NOTES.values())

@app.post("/notes")
def upsert(n: NoteMeta):
    NOTES[n.id] = n.dict()
    return {"ok": True}
