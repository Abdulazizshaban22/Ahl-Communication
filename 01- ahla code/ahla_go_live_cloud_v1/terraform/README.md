# Ahla Go-Live Cloud — Terraform
Build: 2025-10-20T09:04:47.839490Z

> AWS: ينشئ VPC + EKS + Aurora PostgreSQL + IAM OIDC (IRSA). تتطلب مفاتيح AWS صالحة ودور IAM مناسب.

## الخطوات
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```
