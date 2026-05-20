
import os
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
app = FastAPI(title="Ahla Drive API", version="1.2.0")
STORE=os.getenv("STORE","/data"); os.makedirs(STORE, exist_ok=True)

@app.post("/upload")
async def upload(file:UploadFile=File(...)):
    dest=os.path.join(STORE, file.filename)
    with open(dest,"wb") as f: f.write(await file.read())
    return {"ok":True, "name":file.filename, "url": f"/api/drive/files/{file.filename}"}

@app.get("/files/{name}")
def files(name:str): return FileResponse(os.path.join(STORE,name))
