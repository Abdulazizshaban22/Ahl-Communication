import os
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from starlette_exporter import PrometheusMiddleware, handle_metrics
from pathlib import Path
app = FastAPI(title="Ahla Drive API",version="0.1.0")
app.add_middleware(PrometheusMiddleware); app.add_route("/metrics", handle_metrics)

STORE = Path(os.getenv("DRIVE_STORE","/data"))
STORE.mkdir(parents=True, exist_ok=True)

@app.get("/health")
def health(): return {"ok":True}

@app.post("/files")
async def upload(file: UploadFile = File(...)):
    dest = STORE / file.filename
    with open(dest, "wb") as f:
        f.write(await file.read())
    return {"id": file.filename, "size": dest.stat().st_size}

@app.get("/files/{fid}")
def get_file(fid:str):
    path = STORE / fid
    if not path.exists(): raise HTTPException(status_code=404)
    return FileResponse(str(path))
