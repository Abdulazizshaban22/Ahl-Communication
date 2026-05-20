import os, io
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from starlette_exporter import PrometheusMiddleware, handle_metrics
from pathlib import Path
from minio import Minio

app = FastAPI(title="Ahla Drive API",version="0.2.0")
app.add_middleware(PrometheusMiddleware); app.add_route("/metrics", handle_metrics)

STORE = Path(os.getenv("DRIVE_STORE","/data"))
STORE.mkdir(parents=True, exist_ok=True)

MINIO_ENDPOINT=os.getenv("MINIO_ENDPOINT")
MINIO_BUCKET=os.getenv("MINIO_BUCKET","ahla-drive")
MINIO_USER=os.getenv("MINIO_ROOT_USER")
MINIO_PASS=os.getenv("MINIO_ROOT_PASSWORD")
USE_MINIO = bool(MINIO_ENDPOINT)

if USE_MINIO:
    s3 = Minio(MINIO_ENDPOINT, access_key=MINIO_USER, secret_key=MINIO_PASS, secure=False)
    found = s3.bucket_exists(MINIO_BUCKET)
    if not found: s3.make_bucket(MINIO_BUCKET)

@app.get("/health")
def health(): return {"ok":True}

@app.post("/files")
async def upload(file: UploadFile = File(...)):
    content = await file.read()
    if USE_MINIO:
        s3.put_object(MINIO_BUCKET, file.filename, io.BytesIO(content), length=len(content))
    else:
        dest = STORE / file.filename
        with open(dest, "wb") as f: f.write(content)
    # OCR trigger (fire-and-forget via simple file marker)
    if os.getenv("OCR_ENABLED","true").lower()=="true":
        Path(f"/shared/ocr_queue/{file.filename}").write_bytes(content)
    return {"id": file.filename, "size": len(content), "s3": USE_MINIO}

@app.get("/files/{fid}")
def get_file(fid:str):
    if USE_MINIO:
        # For demo we simply save then serve; real impl should stream from S3
        tmp = STORE / fid
        if not tmp.exists():
            data = s3.get_object(MINIO_BUCKET, fid).read()
            with open(tmp,"wb") as f: f.write(data)
        return FileResponse(str(tmp))
    path = STORE / fid
    if not path.exists(): raise HTTPException(status_code=404)
    return FileResponse(str(path))
