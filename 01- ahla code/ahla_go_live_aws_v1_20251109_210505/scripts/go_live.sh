#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../terraform/envs/prod"
terraform init
terraform apply -auto-approve ${TF_VARS:+-var-file="$TF_VARS"}
echo
echo "ALB DNS:"
terraform output alb_dns
