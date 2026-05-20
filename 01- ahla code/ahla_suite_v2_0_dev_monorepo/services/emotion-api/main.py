from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Ahla Emotion API")

class TextIn(BaseModel):
    text: str

def simple_sentiment(text: str) -> dict:
    t = text.lower()
    score = 0
    for w in ["شكرا","ممتاز","جميل","سعيد","Wonderful","great","love"]:
        if w in t: score += 1
    for w in ["غضب","سيء","كاره","حزين","angry","bad","hate"]:
        if w in t: score -= 1
    label = "neutral"
    if score > 0: label = "positive"
    if score < 0: label = "negative"
    return {"label": label, "score": score}

@app.get("/health")
def health():
    return {"ok": True, "service": "emotion-api"}

@app.post("/analyze-text")
def analyze_text(inp: TextIn):
    res = simple_sentiment(inp.text)
    return {"text": inp.text, **res}
