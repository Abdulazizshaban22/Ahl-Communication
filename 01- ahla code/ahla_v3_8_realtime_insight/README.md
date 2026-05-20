# Ahla v3.8 — Realtime Insight Layer

This package provides a production-ready skeleton for a live intelligence dashboard that connects
ASR → Emotion → Suggestions → KPI in real time.

Components:
- **insight-gateway** (FastAPI): Kafka/MSK consumer → WebSocket broadcast (`/ws`) + HTTP snapshots (`/snapshot`).
- **insight-dashboard-next** (Next.js 14 App Router): Real-time UI over WebSocket.
- **insight-dashboard-streamlit** (Streamlit): Optional Python dashboard (HTTP polling).
- **grafana/**: JSON dashboards for SLO & Live metrics.
- **docker-compose.dev.yml**: Run everything locally with Redpanda (Kafka-compatible).

> Production: point the gateway to Amazon MSK Serverless (IAM) and attach Grafana (CloudWatch/OpenSearch).
