from fastapi import FastAPI, UploadFile, File
import os; app = FastAPI(title="Ahla Drive API"); os.makedirs('/data/uploads', exist_ok=True)
@app.post('/api/files/upload') async def upload(f: UploadFile = File(...)):
    dest = os.path.join('/data/uploads', f.filename); open(dest,'wb').write(await f.read()); return {'ok':True,'path':dest}
