# Ahla v3.8.1 — Grafana Live + CloudWatch + Terraform (ECS/CloudFront/MSK) + Next.js WS Route

This package upgrades v3.8 with:
1) **Grafana Live + CloudWatch provisioning** (YAML + dashboards).
2) **Terraform**: ECS/Fargate (Gateway + Next), ALB, CloudFront, MSK Serverless (IAM), WAF (optional).
3) **Next.js WebSocket Route Handler** (`/api/live`) that proxies live snapshots from the gateway.

## Quick start (dev)
- Use docker compose from v3.8 or your own Kafka/MSK.
- Next.js dashboard now connects to **/api/live** (WS) instead of the FastAPI gateway WS.

## Production
- Apply Terraform under `infra/terraform/` (fill `terraform.tfvars` first).
- Provision Grafana with `grafana/provisioning/**` (mount into /etc/grafana/provisioning).
