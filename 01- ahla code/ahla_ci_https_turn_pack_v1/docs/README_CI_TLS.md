# Ahla — CI + HTTPS + TURN Pack
**Date:** 2025-10-19

This pack adds:
- Auto-merge script for legacy UI -> /apps/web/app
- GitHub Actions CI (build) + Deploy (prisma migrate deploy + Docker push to GHCR)
- HTTPS reverse proxy (Caddy auto-HTTPS or Nginx + Certbot TLS)
- CoTURN TLS config (TURNS on 5349) for public WebRTC

## Quick Start
1) Merge old UI
```
chmod +x scripts/merge-old-ui.sh
./scripts/merge-old-ui.sh ../Ahla_Hero_v60_FullSuite .   # add --dry-run to preview
```

2) CI / Deploy
- Commit `.github/workflows/*` and set `DATABASE_URL` secret in repo settings.
- On push to `main`, workflow runs `prisma migrate deploy` then builds & pushes Docker image to GHCR.

3) HTTPS
- **Option A (Caddy)**: mount `deploy/caddy/Caddyfile` and run `caddy:latest` as your proxy.
- **Option B (Nginx + Certbot)**:
  - Install Certbot and run `sudo certbot --nginx` on the host to fetch certs.
  - Use `deploy/nginx/nginx.tls.conf` and mount the /etc/letsencrypt path into the Nginx container.

4) TURN-TLS
- Install certs for your TURN subdomain (e.g., turn.your.domain.com).
- Use `services/coturn/turnserver.tls.conf` with your cert paths.
- Expose 3478 (udp/tcp) and 5349 (tcp) and relay range 49152-49999/udp.
