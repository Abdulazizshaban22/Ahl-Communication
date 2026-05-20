# Ahla Go‑Live v3 Bundle
Build: 2025-10-20T05:11:20.932147Z

This bundle closes gaps and enables 24/7 operation:
- NATS JetStream cluster (3 nodes) with WebSocket
- PostgreSQL primary + replica (streaming replication) bootstrap
- CoTURN TLS/443 config
- Mobile WebSocket Gateway (FastAPI ↔ NATS) JSON bridge
- Feast/Evidently GitHub Actions
- Evidently runner script
- iOS SuperApp seed (SPM modules + SwiftUI demo)
- Quickstart

## Quickstart
1) Edit domain and secrets in `infra/docker-compose-live.yml`
2) `docker compose -f infra/docker-compose-live.yml up -d`
3) Point iOS demo Chat WS to `wss://mobile-gateway.ahla.com/ws/chat`
4) Enable ACME/Certs for TURN/Nginx per your domain setup
