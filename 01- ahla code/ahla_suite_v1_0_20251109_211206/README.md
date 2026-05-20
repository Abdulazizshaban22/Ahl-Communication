
# Ahla Suite v1.0 (Chat + Meet + Drive + Business + Emotion Engine)

## Quick Start (Dev)
```
cd infra
# (اختياري) تعيين مفاتيح VAPID قبل push-worker
export VAPID_PUBLIC_KEY=...
export VAPID_PRIVATE_KEY=...
docker compose up -d --build
```
- Proxy: http://localhost:8080
  - /chat/, /meet/, /drive/, /business/
  - /api/chat/, /api/meet/, /api/drive/, /api/business/, /api/emotion/

## Production (AWS ECS)
- Terraform جاهز في terraform/envs/prod (ALB + HTTPS + Path Routing + ECS Fargate)
- Autoscaling وBlue/Green يمكن تفعيلهما لـweb apps
- أسرار عبر SSM (VAPID)
