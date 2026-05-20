
# Ahla v1.3 — WorkMail/SES + Blue/Green + Logs

## 1) DNS
- Apply `dns/route53_mail_records_example.txt` with your region + DKIM selectors.

## 2) WorkMail + SES
- Follow `docs/WORKMAIL_NOTES.md` then set prod.tfvars for IMAP/SMTP endpoints.

## 3) Canary (Web tier)
- Use `docs/BLUE_GREEN.md` and `bluegreen_examples.tf` then `terraform apply`.

## 4) Observability (Dev)
- `docker compose -f infra/docker-compose.observability.yml up -d`
  - Grafana at http://localhost:3001 (add Loki http://loki:3100)

## 5) OpenSearch (Prod)
- `terraform apply` in env: outputs `opensearch_endpoint`. Wire CloudWatch Logs → (Firehose) → OpenSearch (add later).
