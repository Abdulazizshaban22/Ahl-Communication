# Ahla ASR Service (Ultra v1)
Build: 2025-10-20T09:27:29.033728Z

- Engine: faster-whisper (CTranslate2)
- VAD: webrtcvad
- Exports Prometheus metrics on :9000/metrics

Run:
```bash
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8088
```
