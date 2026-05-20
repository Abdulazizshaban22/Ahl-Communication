from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional, Dict
import re

app = FastAPI(title="Ahla Intel API", version="3.0")

CATEGORIES = ["personal","work","promotion","gratitude","conflict","notification","unknown"]

class AnalyzeIn(BaseModel):
    subject: Optional[str] = ""
    from_addr: Optional[str] = ""
    headers: Dict[str,str] = {}
    text: Optional[str] = ""

class AnalyzeOut(BaseModel):
    label: str
    score: float
    hints: List[str] = []

@app.get("/healthz")
def healthz(): return {"ok": True}

@app.post("/classify", response_model=AnalyzeOut)
def classify(m: AnalyzeIn):
    s = (m.subject or "") + " " + (m.text or "")
    s = s.lower()
    score = 0.75
    if re.search(r"(unsubscribe|promotion|sale|offer|خصم|عرض)", s): return AnalyzeOut(label="promotion", score=score, hints=["unsubscribe/offer"])
    if re.search(r"(شكرا|شكراً|امتنان|thx|thanks|appreciate)", s): return AnalyzeOut(label="gratitude", score=score, hints=["positive/thanks"])
    if re.search(r"(غاضب|زعلان|complain|angry|bad service)", s): return AnalyzeOut(label="conflict", score=score, hints=["negative/conflict"])
    if re.search(r"(invoice|meeting|deadline|project|وظيفة|فاتورة|اجتماع)", s): return AnalyzeOut(label="work", score=score, hints=["work keywords"])
    if re.search(r"(family|حبيب|أمي|أبوي|صديقي|صديقتي)", s): return AnalyzeOut(label="personal", score=score, hints=["relationship/family"])
    if re.search(r"(alert|notification|تم|success|failed|error)", s): return AnalyzeOut(label="notification", score=score, hints=["system/notification"])
    return AnalyzeOut(label="unknown", score=0.5, hints=["fallback"])
