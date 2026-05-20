# Ahla Omni v2
Build: 2025-10-20T04:46:37.996710Z

This package extends v1 with:
- **Chat**: Browser subscribes directly to **NATS WebSocket** (nats.ws). API publishes to NATS **and** persists to Postgres. Import endpoint for WhatsApp JSONL.
- **Drive**: Adds **tusd** (resumable upload). Optionally use S3 **Multipart** (docs included).
- **Meet**: Production **CoTURN 443/TLS** sample config; Meet web consumes ICE from env.
- **Observability**: **OpenTelemetry** auto-instrument for FastAPI services + **Grafana Alloy/Tempo/Loki/Prometheus/Grafana** stack (LGTM).
- **DNS/HTTPS**: TURN TLS template and notes to place valid certs (Let's Encrypt).

Quickstart
- `docker compose -f infra/docker-compose.yml up -d` (brings up tusd, Alloy, Grafana stack, etc.)
- Configure Keycloak client `ahla-web`, set env for apps, then run the Next.js apps.
