
# Ahla Suite v1.2 — Unified
## Dev
cd infra
docker compose up -d
→ http://localhost:8080
- /chat /meet /drive /business /mail

## Prod
cd terraform/envs/prod
terraform init
terraform apply -var-file="prod.tfvars" -auto-approve
