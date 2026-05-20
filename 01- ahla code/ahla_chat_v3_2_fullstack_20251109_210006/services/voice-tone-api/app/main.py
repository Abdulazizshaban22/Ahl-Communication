
import os, subprocess, re, tempfile
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import PlainTextResponse
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="Ahla Voice Tone API", version="0.1.0")
REQS = Counter("ahla_voice_requests_total","Voice tone analyze requests", [])

VOL_RE = re.compile(r"mean_volume:\s*([-0-9\.]+)\s*dB.*?max_volume:\s*([-0-9\.]+)\s*dB", re.S)

@app.get("/metrics")
def metrics():
  return PlainTextResponse(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.post("/analyze")
async def analyze(file: UploadFile = File(...)):
    REQS.inc()
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        data = await file.read()
        tmp.write(data)
        tmp_path = tmp.name
    cmd = ["ffmpeg","-hide_banner","-i", tmp_path, "-af", "volumedetect", "-f", "null", "-"]
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out = p.stderr
    mean, mx = None, None
    m = VOL_RE.search(out)
    if m:
        mean = float(m.group(1)); mx = float(m.group(2))
    level = "calm"
    if mean is not None:
        if mean > -15: level = "intense"
        elif mean > -25: level = "raised"
    try: os.remove(tmp_path)
    except: pass
    return {"mean_dB": mean, "max_dB": mx, "level": level}
