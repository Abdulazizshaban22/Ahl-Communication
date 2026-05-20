import os
from fastapi import FastAPI
from pydantic import BaseModel
from ctranslate2 import Translator
from sentencepiece import SentencePieceProcessor
from prometheus_client import Counter, Histogram, start_http_server

CT2_MODEL_PATH = os.getenv("CT2_MODEL_PATH","./models")
SRC_LANG = os.getenv("SRC_LANG","arb_Arab")
TGT_LANG = os.getenv("TGT_LANG","eng_Latn")

app = FastAPI(title="Ahla Translate Service", version="ultra-v1")
REQS = Counter("translate_requests_total","Translate requests")
LAT = Histogram("translate_request_seconds","Translate latency", buckets=[.05,.1,.25,.5,1,2,4])
start_http_server(9001)

tr = Translator(CT2_MODEL_PATH)
sp = SentencePieceProcessor(model_file=os.path.join(CT2_MODEL_PATH,"spm.model"))

class Req(BaseModel):
    text: str
    src: str | None = None
    tgt: str | None = None

@app.get("/healthz")
def healthz(): return {"ok": True}

@app.post("/v1/translate")
def translate(req: Req):
    REQS.inc()
    src = req.src or SRC_LANG
    tgt = req.tgt or TGT_LANG
    with LAT.time():
        ids = sp.encode(req.text, out_type=int)
        out = tr.translate_batch([ids], source_lang=src, target_lang=tgt, max_batch_size=8)
        detok = sp.decode(out[0].hypotheses[0])
    return {"text": detok, "src": src, "tgt": tgt}
