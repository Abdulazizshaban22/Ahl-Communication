from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import FileResponse, JSONResponse
import os, tempfile, subprocess, uuid, shutil

app = FastAPI(title="Ahla WhatsApp Import API")

@app.post("/upload")
async def upload(file: UploadFile = File(...), self_id: str = Form(...), org: str = Form("ahla"), owner: str = Form(None)):
    tmpdir = tempfile.mkdtemp()
    inpath = os.path.join(tmpdir, file.filename)
    with open(inpath,"wb") as f:
        f.write(await file.read())
    outdir = os.path.join(tmpdir, "out")
    os.makedirs(outdir, exist_ok=True)
    cmd = ["python","/app/whatsapp_import.py","--input",inpath,"--out",outdir,"--self",self_id,"--org",org]
    if owner: cmd += ["--owner", owner]
    cp = subprocess.run(cmd, capture_output=True, text=True)
    if cp.returncode!=0:
        return JSONResponse({"ok":False,"stderr":cp.stderr}, status_code=500)
    zipname = f"/tmp/ahla_import_{uuid.uuid4().hex}.zip"
    shutil.make_archive(zipname[:-4], 'zip', outdir)
    return FileResponse(zipname, filename="ahla_whatsapp_import_result.zip")
