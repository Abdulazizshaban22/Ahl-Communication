import os
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse

STORE = os.getenv("MOMENTS_STORE","/data/moments")
THUMBS = os.getenv("THUMBS_STORE","/data/thumbs")
os.makedirs(STORE, exist_ok=True)
os.makedirs(THUMBS, exist_ok=True)

app = FastAPI(title="Ahla Moments API", version="1.0.1")

@app.get("/health")
def health(): return {"ok":True}

@app.get("/list")
def list_files():
    items = []
    for name in sorted(os.listdir(STORE), reverse=True):
        url = f"/moments/{name}"
        tname = os.path.splitext(name)[0] + ".jpg"
        thumb = f"/thumbs/{tname}" if os.path.exists(os.path.join(THUMBS, tname)) else None
        items.append({"name": name, "url": url, "thumb": thumb})
    return items

@app.post("/upload")
async def upload(file: UploadFile = File(...)):
    name = file.filename
    dest = os.path.join(STORE, name)
    with open(dest, "wb") as f:
        f.write(await file.read())
    return {"ok":True, "name": name, "url": f"/moments/{name}"}

@app.get("/moments/{name}")
def moments_file(name:str):
    path = os.path.join(STORE, name)
    return FileResponse(path)

@app.get("/thumbs/{name}")
def thumbs_file(name:str):
    path = os.path.join(THUMBS, name)
    return FileResponse(path)