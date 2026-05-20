# Ahla Intelligence Fabric — v2.0 Enterprise
**Max production pack** for Ahla Intelligence Fabric (AIF): CloudFront + WAF, MSK (IAM/SASL), ECS Fargate, RDS Postgres (pgvector), Secrets/KMS, Synthetics canary, CI/CD.

## Quick start
1) Fill `infra/terraform/prod.auto.tfvars` (project, region, passwords, ECR repos).
2) In GitHub, set secrets: `AWS_ROLE_TO_ASSUME`, `AWS_REGION`, `AWS_ACCOUNT_ID`, `ECR_ORCH`, `ECR_WORKERS`.
3) Push to `main` or run workflow → builds & pushes images → `terraform apply`.
4) After RDS is up, enable pgvector:
```sql
CREATE EXTENSION IF NOT EXISTS vector;
```
5) Grab outputs:
- `cloudfront_domain_name`, `orchestrator_alb_dns`, `msk_bootstrap_sasl_iam`, `db_endpoint`.

## Components
- **Edge:** CloudFront (public) + WAF (Common + Bot Control + ATP) → ALB (public) with SG limited to the **CloudFront managed prefix list** + header check.
- **Messaging:** MSK (Serverless IAM) *or* MSK provisioned with SASL/SCRAM (toggle via var).
- **Compute:** ECS/Fargate for Orchestrator + 4 Workers.
- **Data:** RDS Postgres 16 + pgvector.
- **Obs:** CloudWatch Logs, Synthetics Canary (/health), Apdex alarm, 5xx alarm; hooks for OpenSearch.
- **CI/CD:** GitHub Actions → ECR → Terraform OIDC.

See `/docs` for details.
