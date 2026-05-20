#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform/envs/prod"
terraform init
if [ -n "${TF_VARS:-}" ]; then
  terraform apply -auto-approve -var-file="$TF_VARS"
else
  terraform apply -auto-approve
fi
terraform output alb_dns
