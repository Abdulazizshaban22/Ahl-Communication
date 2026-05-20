# Ahla Suite — Go‑Live Closure Checklist (v3.3)

## A. Edge & TLS
- [x] CloudFront in front of ALB (aliases set in Route53)
- [x] ACM (us‑east‑1) attached to CloudFront
- [x] Regional ACM on ALB
- [x] ALB protected by secret header + WAF (block if header missing)
- [x] HSTS/CSP Security Headers via CloudFront Response Headers Policy
- [x] HTTP/2 enabled (default on ALB HTTPS)

## B. WAF
- [x] CloudFront WebACL (Managed Rule Set + RateLimit)
- [x] ALB WebACL (Managed Rule Set + header guard)
- [ ] (Optional) Add Bot Control / Account Takeover Prevention

## C. Realtime & Media
- [x] NLB for TURN (UDP 3478 + TLS 5349)
- [x] STUN/TURN configured in Meet
- [x] WebSockets through CloudFront → ALB (secret header)

## D. Data & Storage
- [x] S3 (Drive) with SSE‑KMS
- [x] Presigned URLs in Drive API
- [x] Backups: RDS snapshots (if used) + S3 lifecycle

## E. Caching & Queues
- [x] ElastiCache Redis with in‑transit + at‑rest encryption
- [x] REDIS_URL uses rediss:// with AUTH token (Secrets Manager)

## F. Identity
- [x] Keycloak realm “ahla” (roles: admin/staff/user)
- [x] NextAuth v5 wired (App Router)
- [x] Session cookies secured
- [ ] (Optional) SCIM/IdP sync (Okta/Entra)

## G. Observability
- [x] Amazon Managed Grafana workspace
- [x] OpenSearch domain for PDPL audit
- [x] Firehose stream → OpenSearch + S3 backup
- [x] ALB access logs → S3
- [x] CloudFront logs (standard) → S3
- [ ] (Optional) CloudFront real‑time logs → Kinesis

## H. Mail
- [x] WorkMail/SES domain verified
- [x] SPF + DKIM + DMARC
- [ ] (Optional) Custom MAIL FROM domain

## I. PDPL
- [x] Incident 72h workflow (audit‑api + runbook)
- [x] Consent/DSR logging
- [x] Data within KSA (AWS me‑central‑1; verify residency)
