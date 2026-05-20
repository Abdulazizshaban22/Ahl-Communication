
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Dict

app = FastAPI(title="Ahla Mind API", version="1.0")

class AnalyzeIn(BaseModel):
    chat_id: str
    message_id: str
    author_id: str
    text: str
    context: str = "personal"

class AnalyzeOut(BaseModel):
    sentiment: Dict[str, float]
    flags: List[str]
    suggestions: List[str]

@app.get("/healthz")
def healthz(): return {"ok": True}

@app.post("/analyze", response_model=AnalyzeOut)
def analyze(payload: AnalyzeIn):
    txt = payload.text.lower()
    neg = sum(w in txt for w in ["زعلان","غاضب","سيء","كره","أكره","غلط"]) / 3.0
    pos = sum(w in txt for w in ["أحب","حلو","ممتاز","شكرا","شكرًا","جميل"]) / 3.0
    neu = max(0.0, 1.0 - min(1.0, neg+pos))
    flags = ["high_negative"] if neg > 0.6 else []
    suggestions = []
    if neg > 0.6: suggestions.append("🕊️ خذوا استراحة قصيرة؟")
    if payload.context == "work" and pos > 0.3: suggestions.append("🌟 تبغاني أرسل رسالة شكر؟")
    return AnalyzeOut(sentiment={"positive":float(min(1,pos)), "neutral":float(neu), "negative":float(min(1,neg))},
                      flags=flags, suggestions=suggestions)
