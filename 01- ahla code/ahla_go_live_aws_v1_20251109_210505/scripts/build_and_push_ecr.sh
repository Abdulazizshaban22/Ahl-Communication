#!/usr/bin/env bash
set -euo pipefail
REGION=${REGION:-me-central-1}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

REPOS=(ahla-chat-web ahla-chat-api ahla-moments-api ahla-emotion-api ahla-voice-api ahla-push-worker)

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

for R in "${REOS[@]}"; do
  aws ecr describe-repositories --repository-names "$R" --region $REGION >/dev/null 2>&1 ||     aws ecr create-repository --repository-name "$R" --region $REGION >/dev/null
done

# مثال بناء ودفع (عدّل المسارات حسب مستودعك)
docker build -t ahla-chat-web:prod ../apps/chat-web
docker tag  ahla-chat-web:prod ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/ahla-chat-web:prod
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/ahla-chat-web:prod
