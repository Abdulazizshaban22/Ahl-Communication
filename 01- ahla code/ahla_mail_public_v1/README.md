# Ahla Mail Public v1 (Core) — @ahla.com
Build: 2025-10-19T23:23:34.276079Z

This pack boots a **public email core** using Stalwart (SMTP/IMAP/JMAP) and serves an **MTA-STS** policy.
Match with DNS (SPF, DKIM, DMARC, MTA-STS, TLS-RPT) and open mail ports to run like a real service.

## Run locally
```
cd infra
docker compose up -d
```

- Stalwart admin/JMAP: http://localhost:8080/login
- SMTP: 25,465,587  |  IMAP: 143,993  |  ManageSieve: 4190
- MTA-STS policy (HTTP for now): http://localhost:8088/.well-known/mta-sts.txt

## Production checklist
1) **Public IP + PTR**: set reverse DNS to `mail.ahla.com` (via your host).
2) **TLS**: enable ACME in Stalwart admin or terminate at your reverse proxy (Let's Encrypt).
3) **DNS**: fill `dns/records.template.txt` and publish at your provider.
4) **DKIM**: generate keys (rsa 2048 or ed25519) and publish selector `s1`. Add signer in Stalwart.
5) **DMARC**: start with `p=quarantine` then move to `p=reject` after monitoring reports.
6) **MTA-STS/TLS-RPT**: keep policy served at `https://mta-sts.ahla.com/.well-known/mta-sts.txt`, and publish `_smtp._tls` TXT.
7) **Rate limits & anti-abuse**: configure throttling, RBLs, and spam filter in Stalwart.
8) **Deliverability**: warm up IPs, monitor Google/Yahoo/Microsoft postmaster tools.

See `dns/records.template.txt` for exact records.
