#!/usr/bin/env bash
set -euo pipefail

# Ahla Suite v5 — Go-Live Cloud
# Generated: 2025-10-20T09:44:51.134316Z

if ! command -v helm >/dev/null; then
  curl -L https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz | tar zx
  sudo mv linux-amd64/helm /usr/local/bin/helm
fi
if ! command -v kubectl >/dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl && sudo mv kubectl /usr/local/bin/kubectl
fi

# Expect env vars already set (export before running):
# AWS_REGION, EKS_CLUSTER_NAME
aws eks update-kubeconfig --name "$EKS_CLUSTER_NAME" --region "$AWS_REGION"

# 1) cert-manager issuers (staging + prod)
kubectl apply -f k8s/cert-manager/cluster-issuer-staging.yaml || true
kubectl apply -f k8s/cert-manager/cluster-issuer-prod.yaml || true

# 2) ExternalDNS (choose one)
# helm upgrade -i external-dns oci://registry-1.docker.io/bitnamicharts/external-dns -n external-dns --create-namespace -f k8s/external-dns/values-staging.yaml
# helm upgrade -i external-dns oci://registry-1.docker.io/bitnamicharts/external-dns -n external-dns --create-namespace -f k8s/external-dns/values-prod.yaml

echo "Next steps:"
echo " - Configure GitHub OIDC + secrets (AWS_REGION,EKS_CLUSTER_NAME,AWS_ROLE_TO_ASSUME,ECR_REGISTRY)."
echo " - Push charts to your infra repo, then run 'Deploy Env Overlays' workflow."
echo " - Optionally deploy charts/ahla-shared-ingress and CloudFront template (cloudfront/cloudformation-alb-origin.json)."
