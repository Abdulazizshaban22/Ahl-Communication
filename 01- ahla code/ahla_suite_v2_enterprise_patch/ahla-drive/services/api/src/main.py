from fastapi import FastAPI, UploadFile, File, HTTPException
from minio import Minio
from minio.error import S3Error
import os, io, time

app = FastAPI(title="Ahla Drive API (S3/MinIO)")

ENDPOINT = os.getenv("S3_ENDPOINT","minio:9000")
ACCESS_KEY = os.getenv("S3_ACCESS_KEY","minio")
SECRET_KEY = os.getenv("S3_SECRET_KEY","minio12345")
BUCKET = os.getenv("S3_BUCKET","ahla-uploads")
USE_SSL = os.getenv("S3_USE_SSL","false").lower() == "true"

client = Minio(ENDPOINT, access_key=ACCESS_KEY, secret_key=SECRET_KEY, secure=USE_SSL)

# Ensure bucket
try:
    if not client.bucket_exists(BUCKET):
        client.make_bucket(BUCKET)
except S3Error as e:
    print("S3 init error:", e)

@app.post("/api/files/upload")
async def upload(f: UploadFile = File(...)):
    data = await f.read()
    object_name = f"{int(time.time())}_{f.filename}"
    try:
        client.put_object(BUCKET, object_name, io.BytesIO(data), length=len(data), content_type=f.content_type or "application/octet-stream")
        url = client.presigned_get_object(BUCKET, object_name, expires=60*60)
        return {"ok": True, "bucket": BUCKET, "object": object_name, "url": url}
    except S3Error as e:
        raise HTTPException(status_code=500, detail=str(e))
