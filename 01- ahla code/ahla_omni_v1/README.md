# Ahla Omni Apps v1
Build: 2025-10-20T04:32:37.202442Z

Apps: Chat, Drive, Meet, Business.
Backbone: SSO (Keycloak + NextAuth), NATS JetStream (real-time bus), MinIO (S3), CoTURN (TURN/TLS 443).

Quickstart:
- `docker compose -f infra/docker-compose.yml up -d`
- Set Keycloak realm 'ahla', client 'ahla-web' (OIDC), then copy env into each web app.
- Open apps on localhost ports: Chat(3001), Drive(3002), Meet(3003), Business(3004).
