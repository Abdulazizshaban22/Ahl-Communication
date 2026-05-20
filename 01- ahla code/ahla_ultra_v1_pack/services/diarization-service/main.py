import io, os
from fastapi import FastAPI, UploadFile, HTTPException
from prometheus_client import Counter, Histogram, start_http_server
import soundfile as sf
from pyannote.audio import Pipeline

HF_TOKEN = os.getenv("HF_TOKEN")
if not HF_TOKEN:
    raise RuntimeError("Set HF_TOKEN env var (Hugging Face token)")

pipeline = Pipeline.from_pretrained("pyannote/speaker-diarization", use_auth_token=HF_TOKEN)

app = FastAPI(title="Ahla Diarization Service", version="ultra-v1")
REQS = Counter("diar_requests_total","Diarization requests")
LAT = Histogram("diar_request_seconds","Diarization latency", buckets=[.5,1,2,4,8,16])
start_http_server(9002)

@app.get("/healthz")
def healthz(): return {"ok": True}

@app.post("/v1/diar/file")
def diar_file(file: UploadFile):
    REQS.inc()
    data = file.file.read()
    if not data:
        raise HTTPException(400, "empty file")
    with LAT.time():
        audio, sr = sf.read(io.BytesIO(data))
        diar = pipeline({"waveform": audio, "sample_rate": sr})
        segments = [{"start": float(s.start), "end": float(s.end), "speaker": str(label)}
                    for s, label in diar.itertracks(yield_label=True)]
    return {"segments": segments}
