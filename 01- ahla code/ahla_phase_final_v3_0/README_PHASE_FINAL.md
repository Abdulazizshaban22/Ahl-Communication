# Ahla Suite — Phase‑Final v3.0 (Sovereign Ready 100%)

This add‑on completes the production stack with **(A) ElastiCache Redis (TLS)**, **(B) Amazon Managed Grafana**, **(C) Keycloak Realm (ECS) + SSO wiring**, **(D) PDPL Audit Logging (Firehose → OpenSearch + S3)**, and **(E) CloudFront in front of ALB**.

> Drop these files into your existing Terraform tree (from `ahla_aws_golive_v1` + `ahla_aws_blocks_v1_1`). Files are additive; merge or replace as needed.

## Quick steps
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars  # if you don't have it already
# Add/merge the new variables from terraform.tfvars.append below
terraform init
terraform apply
```
Make sure you have an **ACM certificate in us‑east‑1** for CloudFront and a regional one for ALB.
