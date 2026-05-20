# Ahla Suite — Sovereign+ v2.0 (Dev Monorepo)

**Status:** Runnable dev stack via Docker Compose.  
Services: chat, meet-signaling, drive-api, business-api, mail-api, emotion-api, reverse-proxy (nginx), redis, postgres, minio, coturn, keycloak.

## Quickstart (Dev)
1) Copy `.env.example` to `.env` and adjust as needed.
2) `docker compose up --build`
3) Reverse proxy: http://localhost:8080
   - Chat WS: ws://localhost:8080/ws
   - Meet signaling: http://localhost:8080/meet
   - Drive API: http://localhost:8080/drive
   - Business API: http://localhost:8080/business
   - Mail API: http://localhost:8080/mail
   - Emotion API: http://localhost:8080/emotion

> Notes:
- Coturn is provided for WebRTC connectivity in dev. Use real TURN in prod.
- S3 is emulated using MinIO in dev; use AWS S3 in prod.
- Security: This is a dev stack. Add KMS/PGP/MLS keys in prod.

## Docs
- WebRTC ICE needs STUN/TURN for NAT traversal (MDN).  
- Coturn TURN server Docker image.  
- NestJS WebSockets gateways for Chat.  
- FastAPI for Emotion API.  
- S3 presigned URLs with AWS SDK v3.
