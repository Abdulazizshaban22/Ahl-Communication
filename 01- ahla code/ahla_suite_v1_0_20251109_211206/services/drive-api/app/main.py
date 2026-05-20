
import os
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse, PlainTextResponse
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

STORE = os.getenv("DRIVE_STORE","/data")
os.makedirs(STORE, exist_ok=True)

app = FastAPI(title="Ahla Drive API", version="1.0.0")
UPLOADS = Counter("ahla_drive_uploads","uploads", [])

@app.get("/metrics")
def metrics(): return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/health")
def health(): return {"ok":True}

@app.post("/upload")
async def upload(file: UploadFile = File(...)):
    dest = os.path.join(STORE, file.filename)
    with open(dest,"wb") as f: f.write(await file.read())
    UPLOADS.inc()
    return {"ok":True, "name": file.filename, "url": f"/files/{file.filename}"}

@app.get("/list")
def list_files():
    return [{"name": n, "url": f"/files/{n}"} for n in sorted(os.listdir(STORE))]

@app.get("/files/{name}")
def file(name:str): return FileResponse(os.path.join(STORE,name))
