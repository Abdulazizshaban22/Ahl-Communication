# Ahla Diarization Service (Ultra v1)
Build: 2025-10-20T09:27:29.033728Z

- Engine: pyannote.audio 2.x (speaker diarization).
- Requires `HF_TOKEN` (Hugging Face) to download pipelines with pretrained weights.

Run:
```bash
pip install -r requirements.txt
export HF_TOKEN=hf_xxx
uvicorn main:app --host 0.0.0.0 --port 8090
```
