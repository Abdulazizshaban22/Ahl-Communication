# Ahla v3.7.1 — A+B+C Integration
This package implements:
A) `/v1/asr` wired to **whisper.cpp** (OpenAI-compatible) and **Piper/XTTS** TTS (Arabic) + Dockerfiles.
B) **SageMaker Pipeline** (processors + RegisterModel) + **Model Monitor/Clarify** schedule + Endpoint deploy.
C) **MSK Serverless + IAM** integration (producer/consumer) and topics: `aif.asr`, `aif.emotion`, `aif.suggestions`.

## Quick Dev
- Edit `.env.example` → `.env`
- Run `docker compose -f docker-compose.dev.yml up -d --build`
