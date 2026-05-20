
import re, tempfile, os, subprocess
from fastapi import FastAPI, Body, UploadFile, File
from fastapi.responses import PlainTextResponse
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="Ahla Emotion Engine", version="1.0.0")

TEXT_REQ = Counter("ahla_emotion_text","text", [])
VOICE_REQ = Counter("ahla_emotion_voice","voice", [])

@app.get("/metrics")
def metrics(): return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.post("/analyze/text")
def text(payload: dict = Body(...)):
    text = (payload.get("text") or "").lower()
    score = 0
    bad = ['قذر','غبي','اكره','hate','stupid','idiot']
    for w in bad:
        if w in text: score += 10
    score += text.count('!')*2
    level = 'calm'
    if score >= 18: level='toxic'
    elif score >= 9: level='raised'
    TEXT_REQ.inc()
    return {"score": score, "level": level}

VOL_RE = re.compile(r"mean_volume:\s*([-0-9\.]+)\s*dB.*?max_volume:\s*([-0-9\.]+)\s*dB", re.S)

@app.post("/analyze/voice")
async def voice(file: UploadFile = File(...)):
    VOICE_REQ.inc()
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        data = await file.read()
        tmp.write(data)
        path = tmp.name
    p = subprocess.run(["ffmpeg","-i",path,"-af","volumedetect","-f","null","-"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out = p.stderr
    import math
    mean, mx = None, None
    m = VOL_RE.search(out)
    if m:
        mean = float(m.group(1)); mx = float(m.group(2))
    level = "calm"
    if mean is not None:
        if mean > -15: level="intense"
        elif mean > -25: level="raised"
    try: os.remove(path)
    except: pass
    return {"mean_dB": mean, "max_dB": mx, "level": level}
