#!/usr/bin/env bash
set -euo pipefail
PATCH_DIR="$(cd "$(dirname "$0")" && pwd)"
V4_TF_DIR="../ahla_iac_v4_helm_eks/terraform"

echo "Copying patch .tf files into v4 terraform dir: $V4_TF_DIR"
cp -v "$PATCH_DIR/terraform/patch/"*.tf "$V4_TF_DIR/"
echo "Done. Now edit terraform.tfvars and run:"
echo "cd $V4_TF_DIR && terraform init && terraform apply"
