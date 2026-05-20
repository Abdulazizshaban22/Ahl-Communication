from fastapi import FastAPI
from pydantic import BaseModel
from starlette_exporter import PrometheusMiddleware, handle_metrics

app = FastAPI(title="Ahla Emotion Engine", version="0.1.0")
app.add_middleware(PrometheusMiddleware)
app.add_route("/metrics", handle_metrics)

POS = {"جميل","ممتاز","رائع","شكرا","مبسوط","حلو"}
NEG = {"سيء","زعلان","مشكلة","فشل","تعبان","غضبان"}

class Req(BaseModel):
    text: str

@app.get("/health")
def health():
    return {"status":"ok"}

@app.post("/analyze")
def analyze(r: Req):
    t = r.text
    score = 0
    for w in POS:
        if w in t: score += 1
    for w in NEG:
        if w in t: score -= 1
    mood = "positive" if score>0 else "negative" if score<0 else "neutral"
    return {"mood": mood, "score": score}
