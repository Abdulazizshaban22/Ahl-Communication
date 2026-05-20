from fastapi import FastAPI, Body
app = FastAPI(title="Ahla Emotion API", version="0.1.0")

@app.post("/analyze")
def analyze(payload: dict = Body(...)):
    # Placeholder: rule-based with hooks to plug a ML model (tfjs/onnx) later
    text = (payload.get('text') or '').lower()
    score = 0
    bad = ['قذر','غبي','اكرهك','hate','stupid','idiot']
    for w in bad:
        if w in text: score += 10
    score += text.count('!')*2
    level = 'calm'
    if score >= 18: level = 'toxic'
    elif score >= 9: level = 'raised'
    return {"score": score, "level": level}