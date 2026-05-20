# Ahla Mail Intelligence v3
Build: 2025-10-20T04:21:16.498673Z

- Intel API (/classify) returns label for messages (work/personal/promotion/gratitude/conflict/notification).
- Sieve script reads X-Ahla-LLM and files messages into folders.
- TLS-RPT (RFC 8460) & DMARC RUA (RFC 7489) parsers output CSV for dashboards.

Quick start:
```
cd infra
docker compose up -d --build
# Intel API -> http://localhost:8090/healthz
# Put JSON TLS-RPT files in ../reports/tlsrpt and DMARC XML in ../reports/dmarc_rua
# CSV will be generated into ../out/
```
