# Ahla Intelligence Fabric — v1.1 PROD (AWS ECS/MSK/RDS)

This pack productionizes AIF:
- **MSK (Kafka) with SASL/SCRAM** (managed).
- **RDS PostgreSQL 16** with **pgvector** (Vector DB).
- **ECS Fargate** services (Orchestrator + 4 Workers) with private subnets + ALB (internal by default).
- **Secrets Manager + KMS** for credentials.
- **CloudWatch Logs → OpenSearch** (hook points) + alarms stubs.
- **CI/CD**: GitHub Actions → ECR → Terraform (OIDC).

> Steps:
> 1) Fill `infra/terraform/prod.auto.tfvars`.
> 2) Create ECR repos (or let Terraform create) and push images via CI.
> 3) `cd infra/terraform && terraform init && terraform apply`.

Docs per component inside `docs/`.
