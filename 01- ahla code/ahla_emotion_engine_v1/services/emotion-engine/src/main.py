from fastapi import FastAPI
from fastapi import Body
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
import datetime as dt
import yaml, os
from transformers import pipeline
from .utils import normalize_text

CFG_PATH = os.getenv("AE_CFG", os.path.join(os.path.dirname(__file__), "..", "config", "engine.yaml"))
with open(CFG_PATH, "r", encoding="utf-8") as f:
    CFG = yaml.safe_load(f)

# Pipelines
_sentiment = pipeline("sentiment-analysis", model=CFG["sentiment_model"])
_toxicity  = pipeline("text-classification", model=CFG["toxicity_model"], top_k=None, truncation=True)
_zeroshot  = pipeline("zero-shot-classification", model=CFG["emotion_zeroshot_model"])

GOEMO_LABELS = CFG["goemotions_labels"]

class MessageIn(BaseModel):
    chat_id: str
    message_id: str
    author_id: str
    text: str
    ts: dt.datetime = Field(default_factory=lambda: dt.datetime.now(dt.timezone.utc))
    context: Optional[str] = Field(default=None, description="work or personal if known")

class AnalysisOut(BaseModel):
    sentiment: Dict[str, float]
    toxicity: Dict[str, float]
    top_emotions: List[Dict[str, float]]
    flags: List[str]
    suggestions: List[str]

app = FastAPI(title="Ahla Emotion Engine", version="1.0.0")

def softmax_dict(scored: List[dict]) -> Dict[str, float]:
    import math
    exps = [math.exp(x['score']) for x in scored]
    s = sum(exps) or 1.0
    return {x['label'].lower(): exps[i]/s for i, x in enumerate(scored)}

def map_sentiment(label: str) -> Dict[str, float]:
    # Normalize common labels to pos/neu/neg
    l = label.lower()
    if "pos" in l: return {"positive": 1.0, "neutral": 0.0, "negative": 0.0}
    if "neg" in l: return {"positive": 0.0, "neutral": 0.0, "negative": 1.0}
    return {"positive": 0.0, "neutral": 1.0, "negative": 0.0}

def infer_emotion_zeroshot(text: str) -> List[Dict[str, float]]:
    zs = _zeroshot(text, GOEMO_LABELS, multi_label=True)
    pairs = list(zip(zs["labels"], zs["scores"]))
    pairs.sort(key=lambda x: x[1], reverse=True)
    return [{k: float(v)} for k,v in pairs[:5]]

def apply_rules(analysis: AnalysisOut, msg: MessageIn, history: List[AnalysisOut]) -> List[str]:
    rules = CFG["rules"]
    suggests = []

    # 1) anger cooloff
    anger_t = rules["anger_suggest_cooloff"]["anger_threshold"]
    min_conflicts = rules["anger_suggest_cooloff"]["min_conflicts"]
    # count anger in history (using top_emotions)
    anger_hits = 0
    for h in history:
        for e in h.top_emotions:
            if "anger" in e:
                if e["anger"] >= anger_t:
                    anger_hits += 1
                    break
    if anger_hits >= min_conflicts:
        suggests.append("🕊️ خذوا استراحة قصيرة وكمّلوا كلامكم لاحقًا. أذكّركم بعد ساعة؟")

    # 2) praise -> thanks (work)
    if msg.context == "work":
        joy = analysis.top_emotions[0].get("joy", 0.0) if analysis.top_emotions else 0.0
        if joy >= rules["praise_suggest_thanks"]["joy_threshold"]:
            suggests.append("🌟 واضح إنك مبسوط من الشغل. تبغاني أجهّز رسالة شكر راقية؟")

    # 3) night overwork (late hours)
    hh = msg.ts.hour
    if hh >= CFG["rules"]["night_overwork"]["hour_start"]:
        suggests.append("🌙 تواصل متأخر متكرر. تبغاني أذكّر الفريق بوقت راحة؟")

    return suggests

@app.post("/analyze", response_model=AnalysisOut)
def analyze(m: MessageIn, history: Optional[List[AnalysisOut]] = Body(default=[])):
    text = normalize_text(m.text)
    # 1) sentiment
    s = _sentiment(text)[0]
    sentiment = map_sentiment(s['label'])
    # 2) toxicity (multi-label -> dict of label:prob)
    tox_raw = _toxicity(text)
    # tox_raw is list of lists (top_k=None), flatten
    flat = tox_raw[0] if isinstance(tox_raw, list) and isinstance(tox_raw[0], list) else tox_raw
    toxicity = softmax_dict(flat if isinstance(flat, list) else [flat])
    # 3) emotions (zero-shot on GoEmotions)
    emos = infer_emotion_zeroshot(text)

    # flags
    flags = []
    if toxicity.get("toxic", 0.0) > 0.5 or toxicity.get("insult", 0.0) > 0.5:
        flags.append("toxic_like")
    if sentiment["negative"] > 0.7:
        flags.append("high_negative")

    out = AnalysisOut(
        sentiment=sentiment,
        toxicity=toxicity,
        top_emotions=emos,
        flags=flags,
        suggestions=[]
    )
    out.suggestions = apply_rules(out, m, history or [])
    return out

@app.get("/healthz")
def healthz():
    return {"ok": True}
