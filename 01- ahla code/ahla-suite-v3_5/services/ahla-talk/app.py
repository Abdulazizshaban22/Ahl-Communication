
from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
import os, requests

app = FastAPI(title="Ahla Talk", version="1.0")

WHISPER_BASE = os.getenv("WHISPER_BASE_URL","http://whisper:2022/v1")
PIPER_HTTP = os.getenv("PIPER_HTTP_URL","http://piper:5500")
XTTS_URL = os.getenv("XTTS_URL","http://xtts:8020")

class TTSIn(BaseModel):
    text: str
    voice: str | None = None
    provider: str | None = "piper"  # or xtts

@app.post("/asr")
async def asr(file: UploadFile = File(...)):
    # Proxy to OpenAI-compatible Whisper server (whisper.cpp / llamaedge)
    url = f"{WHISPER_BASE}/audio/transcriptions"
    files = {"file": (file.filename, await file.read(), file.content_type)}
    data = {"model": "whisper-1"}
    r = requests.post(url, files=files, data=data, timeout=120)
    r.raise_for_status()
    return r.json()

@app.post("/tts")
def tts(inp: TTSIn):
    if (inp.provider or "piper").lower()=="piper":
        # Simple Piper HTTP server proxy; expects /speak?text=&voice=
        resp = requests.get(f"{PIPER_HTTP}/speak", params={"text": inp.text, "voice": inp.voice or "ar_JO"},
                            timeout=60)
        resp.raise_for_status()
        return {"audio_url": resp.json().get("url","")}
    else:
        # Coqui XTTS inference proxy (example)
        r = requests.post(f"{XTTS_URL}/tts", json={"text": inp.text, "speaker_wav": None, "language": "ar"},
                          timeout=60)
        r.raise_for_status()
        return {"audio_url": r.json().get("url","")}

@app.get("/health")
def health():
    return {"ok": True}
