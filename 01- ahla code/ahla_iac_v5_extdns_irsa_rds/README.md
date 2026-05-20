# Ahla IaC v5 — ExternalDNS (IRSA) + Amazon RDS for PostgreSQL
Build: 2025-10-20T05:21:01.768150Z

This upgrade replaces in‑cluster PostgreSQL with **Amazon RDS (Multi‑AZ)** and configures **ExternalDNS with Route53 using IRSA**.

## What’s included
- Terraform:
  - IAM Role + Policy (least‑privilege) for ExternalDNS (IRSA)
  - Helm release of external‑dns **bound to the IRSA role**
  - Amazon RDS for PostgreSQL (Multi‑AZ instance), security groups, subnet group
  - Optional **RDS Proxy** (toggle) for connection pooling
  - K8s Secret with DB URL for apps (`ahla-system/db-url`)
- Step‑by‑step migration notes

## Quick start
1) In `terraform/terraform.tfvars` set: `region`, `domain = "ahla.com"`, `hosted_zone_id`, DB size/class, etc.
2) `terraform init && terraform apply`
3) Remove/disable in‑cluster PostgreSQL helm release if previously installed.
4) Point your apps to Secret `ahla-system/db-url`.

See docs cited inline in code comments for reference.
