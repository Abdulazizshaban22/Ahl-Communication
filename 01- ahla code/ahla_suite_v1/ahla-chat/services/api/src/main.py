from fastapi import FastAPI
from pydantic import BaseModel
import datetime as dt
app = FastAPI(title="Ahla Chat API")
class Msg(BaseModel): chat_id:str; text:str
@app.get('/healthz') def healthz(): return {'ok':True}
@app.post('/api/messages') def post_msg(m: Msg): return {'ok':True,'ts':dt.datetime.utcnow().isoformat()}
