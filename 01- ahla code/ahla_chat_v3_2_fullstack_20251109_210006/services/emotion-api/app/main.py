
from fastapi import FastAPI, Body
from fastapi.responses import PlainTextResponse
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
app = FastAPI(title="Ahla Emotion API", version="0.3.0")

REQS = Counter("ahla_emotion_requests_total","Emotion analyze requests", [])

@app.get("/metrics")
def metrics():
  return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.post("/analyze")
def analyze(payload: dict = Body(...)):
    text = (payload.get('text') or '').lower()
    score = 0
    bad = ['قذر','غبي','اكرهك','hate','stupid','idiot']
    for w in bad:
        if w in text: score += 10
    score += text.count('!')*2
    level = 'calm'
    if score >= 18: level = 'toxic'
    elif score >= 9: level = 'raised'
    REQS.inc()
    return {"score": score, "level": level}
