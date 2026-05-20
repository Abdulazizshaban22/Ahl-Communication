
from fastapi import FastAPI, Body
app = FastAPI(title="Ahla Emotion Engine", version="1.2.0")

@app.post("/analyze/text")
def analyze_text(body:dict=Body(...)):
    text = (body.get("text") or "").lower()
    score = 0
    score += 1 if "شكرا" in text else 0
    score -= 1 if "غضب" in text or "زعلان" in text else 0
    return {"sentiment": "positive" if score>0 else "negative" if score<0 else "neutral", "score": score}

@app.get("/health")
def health(): return {"ok":True}
