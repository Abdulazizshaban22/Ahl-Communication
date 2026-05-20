import io, time
from fastapi import FastAPI, UploadFile, HTTPException
from faster_whisper import WhisperModel
from prometheus_client import Counter, Histogram, start_http_server
import soundfile as sf

app = FastAPI(title="Ahla ASR Service", version="ultra-v1")

REQS = Counter("asr_requests_total","ASR requests")
LAT = Histogram("asr_request_seconds", "ASR request latency", buckets=[.25,.5,1,2,4,8,16])

model = WhisperModel("medium", compute_type="int8_float16")
start_http_server(9000)

@app.get("/healthz")
def healthz():
    return {"ok": True}

@app.post("/v1/asr/file")
def asr_file(file: UploadFile):
    REQS.inc()
    data = file.file.read()
    if not data:
        raise HTTPException(400, "empty file")
    with LAT.time():
        audio, sr = sf.read(io.BytesIO(data))
        # Let faster-whisper apply its VAD filter
        segments, info = model.transcribe(audio, language="ar", vad_filter=True)
        text = " ".join(s.text for s in segments)
    return {"text": text, "language": info.language, "duration": info.duration}
