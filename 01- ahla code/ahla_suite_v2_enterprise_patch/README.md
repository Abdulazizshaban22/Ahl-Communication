# Ahla Suite v2 — Enterprise Patch
Build: 2025-10-19T23:19:00.302073Z

This patch adds:
- SSO (Keycloak) wiring for all Next.js apps via NextAuth.
- S3/MinIO media storage in Drive API.
- NATS JetStream publisher in Chat API and consumer in Mind.
- TURN TLS config targeting domain `ahla.com` (coturn).
- pgvector bootstrap SQL and example.
- NGINX TLS sample for subdomains.

Apply: copy files to the corresponding folders in your existing `ahla_suite_v1` checkout.
Then run: `cd infra && docker compose -f docker-compose.yml -f docker-compose.override.yml up -d --build`.
