from fastapi import FastAPI, Body
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
import datetime as dt, os, yaml, asyncio, json

from transformers import pipeline
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

# Feast
from feast import FeatureStore, RepoConfig
# NATS
import nats

CFG_PATH = os.getenv("AE_CFG", os.path.join(os.path.dirname(__file__), "..", "config", "engine.yaml"))
with open(CFG_PATH, "r", encoding="utf-8") as f:
    CFG = yaml.safe_load(f)

app = FastAPI(title="Ahla Emotion Engine v3", version="3.0.0")
FastAPIInstrumentor.instrument_app(app)

# Lazy init
_sentiment = pipeline("sentiment-analysis", model=CFG["sentiment_model"])
_toxicity  = pipeline("text-classification", model=CFG["toxicity_model"], top_k=None, truncation=True)
_zeroshot  = pipeline("zero-shot-classification", model=CFG["emotion_zeroshot_model"])
GOEMO_LABELS = CFG["goemotions_labels"]

# Feast store
FS = FeatureStore(repo_path=CFG["feast"]["repo_path"]) if os.path.isdir(CFG["feast"]["repo_path"]) else None
# NATS connection (lazy)
NC = None

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

def softmax_dict(scored: List[dict]) -> Dict[str, float]:
    import math
    exps = [math.exp(x['score']) for x in scored]
    s = sum(exps) or 1.0
    return {x['label'].lower(): exps[i]/s for i, x in enumerate(scored)}

def map_sentiment(label: str) -> Dict[str, float]:
    l = label.lower()
    if "pos" in l: return {"positive": 1.0, "neutral": 0.0, "negative": 0.0}
    if "neg" in l: return {"positive": 0.0, "neutral": 0.0, "negative": 1.0}
    return {"positive": 0.0, "neutral": 1.0, "negative": 0.0}

def infer_emotion_zeroshot(text: str) -> List[Dict[str, float]]:
    zs = _zeroshot(text, GOEMO_LABELS, multi_label=True)
    pairs = list(zip(zs["labels"], zs["scores"]))
    pairs.sort(key=lambda x: x[1], reverse=True)
    return [{k.lower(): float(v)} for k,v in pairs[:5]]

def load_feats(chat_id: str) -> Dict[str, float]:
    """Fetch features from Feast (if available)."""
    if not FS:
      return {}
    try:
      feats = FS.get_online_features(
        features=[
          "chat_metrics:conflict_count_30d",
          "chat_metrics:praise_count_7d",
          "chat_metrics:night_msgs_14d",
          "chat_metrics:avg_response_hours_7d",
        ],
        entity_rows=[{"chat_id": chat_id}],
      ).to_dict()
      # Feast returns dict of lists; flatten first element
      return {k: (v[0] if isinstance(v, list) else v) for k,v in feats.items()}
    except Exception as e:
      return {}

async def nats_publish_lowconf(payload: dict):
    global NC
    if NC is None:
        try:
            NC = await nats.connect(CFG["nats"]["url"])
        except Exception:
            return
    subj = CFG["nats"]["subject_lowconf"]
    await NC.publish(subj, json.dumps(payload, ensure_ascii=False).encode("utf-8"))

def apply_rules(analysis: AnalysisOut, m: MessageIn, hist: List[AnalysisOut], feats: Dict[str, float]) -> List[str]:
    R = CFG["rules"]; S: List[str] = []

    # --- anger cooloff with escalation ---
    anger_t = R["anger_cooloff"]["anger_threshold"]
    hits = 0
    for h in hist:
        for e in h.top_emotions:
            if "anger" in e and e["anger"] >= anger_t:
                hits += 1; break
    if hits >= R["anger_cooloff"]["min_conflicts"]:
        levels = R["anger_cooloff"]["escalation_levels"]
        level_idx = min(len(levels)-1, hits - R["anger_cooloff"]["min_conflicts"])
        S.append(levels[level_idx])

    # --- reconciliation after silence ---
    if feats.get("conflict_count_30d", 0) >= R["reconciliation"]["negative_bursts_min"]:
        # if recent silence days threshold met (approx via avg_response_hours_7d)
        if feats.get("avg_response_hours_7d", 0) >= R["reconciliation"]["silent_days_after"] * 24:
            S.append(R["reconciliation"]["suggestion"])

    # --- appreciation in work context ---
    joy = (analysis.top_emotions[0].get("joy", 0.0) if analysis.top_emotions else 0.0)
    if (m.context == "work" and joy >= R["appreciation_work"]["joy_threshold"]) or feats.get("praise_count_7d",0) >= R["appreciation_work"]["min_praise_last7d"]:
        S.append(R["appreciation_work"]["suggestion"])

    # --- burnout signal (night activity + negative trend) ---
    if feats.get("night_msgs_14d", 0) >= R["burnout_signal"]["night_msgs_min_14d"] and analysis.sentiment.get("negative",0) > R["burnout_signal"]["negative_trend_threshold"]:
        S.append(R["burnout_signal"]["suggestion"])

    # --- social debt (unanswered) --- (approx via avg response hours > threshold)
    if feats.get("avg_response_hours_7d", 0) >= R["social_debt"]["unanswered_hours"]:
        S.append(R["social_debt"]["suggestion"])

    # --- check-in after long silence ---
    # If no features, fall back to message timestamp-driven heuristic (not implemented here)
    if feats.get("avg_response_hours_7d", 0) >= R["check_in_after_silence"]["silence_days"] * 24:
        S.append(R["check_in_after_silence"]["suggestion"])

    return list(dict.fromkeys(S))  # de-duplicate preserving order

@app.post("/analyze", response_model=AnalysisOut)
def analyze(m: MessageIn, history: Optional[List[AnalysisOut]] = Body(default=[])):
    s = _sentiment(m.text)[0]
    sentiment = map_sentiment(s['label'])
    tox_raw = _toxicity(m.text)
    flat = tox_raw[0] if isinstance(tox_raw, list) and isinstance(tox_raw[0], list) else tox_raw
    toxicity = softmax_dict(flat if isinstance(flat, list) else [flat])
    emos = infer_emotion_zeroshot(m.text)

    flags = []
    if toxicity.get("toxic", 0.0) > 0.5 or toxicity.get("insult", 0.0) > 0.5:
        flags.append("toxic_like")
    if sentiment["negative"] > 0.7:
        flags.append("high_negative")

    # fetch features from Feast
    feats = load_feats(m.chat_id)

    out = AnalysisOut(sentiment=sentiment, toxicity=toxicity, top_emotions=emos, flags=flags, suggestions=[])
    out.suggestions = apply_rules(out, m, history or [], feats)

    # low-confidence/flag triage to NATS (example condition)
    if "toxic_like" in flags and sentiment["negative"] > 0.5:
        try:
            asyncio.get_event_loop().create_task(nats_publish_lowconf({
                "chat_id": m.chat_id, "message_id": m.message_id, "author_id": m.author_id,
                "text": m.text, "sentiment": sentiment, "toxicity": toxicity, "emotions": emos
            }))
        except RuntimeError:
            # if no loop (sync context), ignore
            pass

    return out

@app.get("/healthz")
def healthz(): return {"ok": True}
