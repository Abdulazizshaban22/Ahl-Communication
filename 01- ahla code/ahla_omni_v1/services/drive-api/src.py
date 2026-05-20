from fastapi import FastAPI
from pydantic import BaseModel
from minio import Minio
import os, datetime

MINIO_ENDPOINT=os.getenv("MINIO_ENDPOINT","localhost")
MINIO_PORT=int(os.getenv("MINIO_PORT","9000"))
ACCESS=os.getenv("MINIO_ACCESS_KEY","minioadmin")
SECRET=os.getenv("MINIO_SECRET_KEY","minioadmin")
USE_SSL=os.getenv("MINIO_USE_SSL","false").lower()=="true"
BUCKET=os.getenv("MINIO_BUCKET","ahla")

mc = Minio(f"{MINIO_ENDPOINT}:{MINIO_PORT}", access_key=ACCESS, secret_key=SECRET, secure=USE_SSL)

app = FastAPI(title="Ahla Drive API")

@app.on_event("startup")
def startup():
    found = mc.bucket_exists(BUCKET)
    if not found: mc.make_bucket(BUCKET)

@app.get("/healthz")
def healthz(): return {"ok": True}

class PresignIn(BaseModel):
    object_name: str
    method: str = "put"  # "put" or "get"
    expiry_seconds: int = 3600

@app.post("/presign")
def presign(p: PresignIn):
    if p.method.lower()=="put":
        url = mc.presigned_put_object(BUCKET, p.object_name, expires=datetime.timedelta(seconds=p.expiry_seconds))
    else:
        url = mc.presigned_get_object(BUCKET, p.object_name, expires=datetime.timedelta(seconds=p.expiry_seconds))
    return {"url": url}
