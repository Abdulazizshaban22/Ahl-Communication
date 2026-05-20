from fastapi import FastAPI, UploadFile, File, Body
from pydantic import BaseModel
import os, requests

app = FastAPI(title="Ahla ASR/TTS Proxy", version="1.0")

WHISPER = os.getenv("WHISPER_BASE_URL","http://localhost:2022/v1")
PIPER = os.getenv("PIPER_HTTP_URL","http://localhost:5500")
XTTS  = os.getenv("XTTS_URL","http://localhost:8020")

class TTSIn(BaseModel):
    text: str
    voice: str | None = None
    provider: str | None = "piper"  # piper|xtts

@app.post("/v1/asr")
async def asr(file: UploadFile = File(...)):
    # OpenAI-compatible endpoint exposed by whisper.cpp/faster-whisper server
    url = f"{WHISPER}/audio/transcriptions"
    files = { "file": (file.filename, await file.read(), file.content_type or "audio/wav") }
    data = { "model": "whisper-1", "language": "ar" }
    r = requests.post(url, files=files, data=data, timeout=120)
    r.raise_for_status()
    return r.json()

@app.post("/v1/tts")
def tts(inp: TTSIn):
    provider = (inp.provider or "piper").lower()
    if provider == "piper":
        # Piper HTTP server convention: /speak?text=&voice=ar-XX
        resp = requests.get(f"{PIPER}/speak", params={"text": inp.text, "voice": inp.voice or "ar_XA"}, timeout=60)
        resp.raise_for_status()
        return resp.json()
    else:
        # Coqui XTTS gateway (community servers expose REST /tts)
        r = requests.post(f"{XTTS}/tts", json={"text": inp.text, "language": "ar", "speaker_wav": None}, timeout=60)
        r.raise_for_status()
        return r.json()

@app.get("/health")
def health():
    return {"ok": True}
