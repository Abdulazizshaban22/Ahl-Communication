# Ahla v3.6 — Secure Meet (SFrame/MLS) + SLO Dashboards + WAF ACFP

## 1) Meet E2EE (SFrame + Insertable Streams)
- Import `ahla-meet/e2ee/sender.js` and `receiver.js` into your Meet web app.
- Replace `sframe.js` with a production SFrame implementation.
- Request SFrame keys from MLS server per-room and per-epoch.

## 2) MLS Keying
- Build the Rust skeleton under `ahla-meet/mls` using OpenMLS.
- Expose REST endpoints to issue new epochs and export `exportSecret("sframe")` to authenticated members only.

## 3) Observability
- Import Grafana dashboards from `observability/grafana/*.json`.
- On ECS: run CloudWatch Agent using `observability/cloudwatch/cw-agent-config.json` and set `AHLA_SERVICE`.
- Use Application Signals/SLO for burn-rate alerts.

## 4) WAF ACFP
- Apply `infra/terraform/waf_acfp.tf` and associate with your CloudFront distribution.
- Enable the client-side AWS WAF JS integration token on `/auth/*` pages before submit.
