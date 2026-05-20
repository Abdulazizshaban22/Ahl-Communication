
import os
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse, PlainTextResponse
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

STORE = os.getenv("MOMENTS_STORE","/data/moments")
THUMBS = os.getenv("THUMBS_STORE","/data/thumbs")
os.makedirs(STORE, exist_ok=True)
os.makedirs(THUMBS, exist_ok=True)

app = FastAPI(title="Ahla Moments API", version="1.1.0")
UPLOADS = Counter("ahla_moments_uploads_total","Moments uploads", [])

@app.get("/metrics")
def metrics():
    return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/health")
def health(): return {"ok":True}

@app.get("/list")
def list_files():
    items = []
    for name in sorted(os.listdir(STORE), reverse=True):
        url = f"/moments/{name}"
        items.append({"name": name, "url": url})
    return items

@app.post("/upload")
async def upload(file: UploadFile = File(...)):
    name = file.filename
    dest = os.path.join(STORE, name)
    with open(dest, "wb") as f:
        f.write(await file.read())
    UPLOADS.inc()
    return {"ok":True, "name": name, "url": f"/moments/{name}"}

@app.get("/moments/{name}")
def moments_file(name:str):
    path = os.path.join(STORE, name)
    return FileResponse(path)
