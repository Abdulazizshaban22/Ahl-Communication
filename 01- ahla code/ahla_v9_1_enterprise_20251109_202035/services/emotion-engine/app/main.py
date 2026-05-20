from fastapi import FastAPI
from pydantic import BaseModel
from starlette_exporter import PrometheusMiddleware, handle_metrics

app = FastAPI(title="Ahla Emotion Engine",version="0.2.0")
app.add_middleware(PrometheusMiddleware); app.add_route("/metrics", handle_metrics)

class Req(BaseModel):
    text: str

@app.get("/health")
def health(): return {"ok":True}

@app.post("/analyze")
def analyze(r:Req):
    t = r.text
    score = 1 if any(w in t for w in ["ممتاز","جميل","حلو","شكرا"]) else -1 if any(w in t for w in ["سيء","زعلان","غضب"]) else 0
    mood = "positive" if score>0 else "negative" if score<0 else "neutral"
    return {"mood": mood, "score": score}

@app.post("/tone")
def tone(r:Req):
    intensity = 0.9 if "!!!" in r.text or r.text.isupper() else 0.3
    return {"tone":"aggressive" if intensity>0.7 else "calm","intensity":intensity}
