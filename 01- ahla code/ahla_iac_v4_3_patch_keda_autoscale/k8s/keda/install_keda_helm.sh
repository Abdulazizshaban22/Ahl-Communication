#!/usr/bin/env bash
set -euo pipefail
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm upgrade --install keda kedacore/keda -n keda --create-namespace
kubectl -n keda get pods
