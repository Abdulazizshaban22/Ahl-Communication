# Ahla — FullSuite v2 Go-Live
**Date:** 2025-10-19

حزمة موحّدة تجمع: Assembly + CI/TLS، وجاهزة للنشر.

## Quick Start
1) شغّل الكور:
   ```bash
   docker compose -f deploy/docker-compose.core.yml up -d
   ```
2) داخل `apps/web`:
   ```bash
   npm i
   npx prisma generate
   npx prisma migrate dev --name init   # للتطوير
   node scripts/seed-admin.js
   npm run dev
   ```
3) (اختياري) المكالمات:
   ```bash
   docker compose -f deploy/docker-compose.sfu.yml up -d
   ```
4) HTTPS:
   - **Caddy** يوفر HTTPS تلقائيًا (ACME). راجع `deploy/caddy/Caddyfile`.
   - أو **Nginx + Certbot** باستخدام `deploy/nginx/nginx.tls.conf`.

## CI/CD
- **deploy.yml**: على push إلى main → `prisma migrate deploy` (إنتاج) ثم Build & Push لصور Docker (GHCR).
- **ci.yml**: بناء عام وتشغيل Prisma generate.
