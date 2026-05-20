#!/usr/bin/env bash
set -e
cd infra/terraform
terraform init
terraform apply -auto-approve -var-file=env/terraform.tfvars