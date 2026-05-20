from fastapi import FastAPI
from pydantic import BaseModel
app = FastAPI(title="Ahla Mail API")
class DraftIn(BaseModel): subject:str; body:str; tone:str='friendly'
@app.post('/api/drafts/suggest') def draft(d: DraftIn): return {'draft': f'[{d.tone}] رد مقترح على: {d.subject}\n\nشكراً لتواصلكم...'}
