# Ahla Mail Config v2 — Live Ready
Build: 2025-10-19T23:32:59.746496Z

This pack contains ready configs for:
- Stalwart Mail Server (with ACME + DKIM)
- NGINX + Traefik templates for mta-sts.ahla.com
- Full ahla.com DNS zonefile (SPF/DKIM/DMARC/MTA-STS/TLS-RPT/BIMI)

## Steps
1) Place Stalwart config under /opt/stalwart/config.toml
2) Mount keys under /opt/stalwart/keys/
3) Run: `docker restart ahla-mail`
4) For mta-sts, deploy nginx or traefik config + certbot if not using ACME internal.
5) Publish DNS zone file records at registrar.
