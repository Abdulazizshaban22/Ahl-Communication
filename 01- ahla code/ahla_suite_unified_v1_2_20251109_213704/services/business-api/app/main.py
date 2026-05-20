
import uuid
from fastapi import FastAPI, Body
app = FastAPI(title="Ahla Business API", version="1.2.0")
TASKS=[]

@app.get("/tasks")
def tasks(): return TASKS

@app.post("/tasks")
def add(task:dict=Body(...)):
    t={"id":str(uuid.uuid4()),"title":task.get("title","Untitled")}
    TASKS.append(t); return t
