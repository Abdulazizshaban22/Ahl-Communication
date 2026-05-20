import os
from fastapi import FastAPI
from pydantic import BaseModel
from starlette_exporter import PrometheusMiddleware, handle_metrics

USE_ONNX = os.getenv("USE_ONNX","false").lower()=="true"
ONNX_PATH = os.getenv("ONNX_PATH","/models/model.onnx")

app = FastAPI(title="Ahla Emotion Engine", version="0.2.0")
app.add_middleware(PrometheusMiddleware)
app.add_route("/metrics", handle_metrics)

POS = {"جميل","ممتاز","رائع","شكرا","مبسوط","حلو","تمام"}
NEG = {"سيء","زعلان","مشكلة","فشل","تعبان","غضبان","تأخير"}

class Req(BaseModel):
    text: str

_session = None
tokenizer = None

def _load():
    global _session
    if USE_ONNX and os.path.exists(ONNX_PATH):
        try:
            import onnxruntime as ort
            _session = ort.InferenceSession(ONNX_PATH, providers=['CPUExecutionProvider'])
        except Exception:
            _session = None

@ app.on_event("startup")
def startup():
    _load()

@app.get("/health")
def health():
    return {"status":"ok", "onnx": bool(_session is not None)}

@app.post("/analyze")
def analyze(r: Req):
    text = r.text
    if _session:
        # placeholder: simple length-based score for demo
        score = (len(text) % 5) - 2
    else:
        score = 0
        for w in POS:
            if w in text: score += 1
        for w in NEG:
            if w in text: score -= 1
    mood = "positive" if score>0 else "negative" if score<0 else "neutral"
    return {"mood": mood, "score": int(score)}
