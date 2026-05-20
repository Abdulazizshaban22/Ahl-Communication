
# Ahla — Go-Live Runbook
1) Build & Push images to ECR (`scripts/build_and_push_ecr.sh`).
2) Create SSM params for VAPID keys:
   - /ahla/vapid/public
   - /ahla/vapid/private
3) Fill `terraform/envs/prod/prod.tfvars` and run `scripts/go_live.sh`.
4) Validate:
   - https://YOUR_DOMAIN/chat  → opens UI
   - /api/* paths respond with 200/health
5) CodeDeploy (chat-web):
   - New image → create deployment referencing the new Task Definition
   - Traffic shifts between BLUE/GREEN via listener 443 / test 8080.
