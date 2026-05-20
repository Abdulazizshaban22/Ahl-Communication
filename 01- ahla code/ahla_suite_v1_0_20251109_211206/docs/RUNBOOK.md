
# Ahla Suite v1.0 — Runbook
## Dev (Docker Compose)
cd infra && docker compose up -d --build
- بوابة: http://localhost:8080
- Grafana: http://localhost:3001 (admin/admin)

## Prod (AWS ECS)
1) شغّل scripts/build_and_push_ecr.sh
2) أنشئ SSM Parameters لمفاتيح VAPID
3) املأ terraform/envs/prod/prod.tfvars
4) scripts/go_live.sh
