
from fastapi import FastAPI
from pydantic import BaseModel
import os

app = FastAPI(title="Ahla Emotion", version="1.0")

# Lazy-load transformer to keep container light during build
MODEL_NAME = os.getenv("EMOTION_MODEL","CAMeL-Lab/bert-base-arabic-camelbert-da-sentiment")
_pipeline = None

class TextIn(BaseModel):
    text: str

def get_pipeline():
    global _pipeline
    if _pipeline is None:
        from transformers import AutoTokenizer, AutoModelForSequenceClassification, pipeline
        tok = AutoTokenizer.from_pretrained(MODEL_NAME)
        mdl = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)
        _pipeline = pipeline("text-classification", model=mdl, tokenizer=tok, return_all_scores=True)
    return _pipeline

@app.post("/analyze_text")
def analyze_text(inp: TextIn):
    nlp = get_pipeline()
    scores = nlp(inp.text)[0]
    # Normalize to [-1,1] sentiment and provide labels
    mapping = {"negative": -1.0, "neutral": 0.0, "positive": 1.0}
    best = max(scores, key=lambda s: s["score"])
    sentiment = mapping.get(best["label"].lower(), 0.0)
    return {"label": best["label"], "score": best["score"], "sentiment": sentiment, "all": scores}

@app.get("/health")
def health():
    return {"ok": True}
