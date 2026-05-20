#!/usr/bin/env bash
set -euo pipefail
NAMESPACE=ahla-system
helm upgrade --install monitoring helm/monitoring -n monitoring --create-namespace
helm upgrade --install ahla-cloud helm/ahla-cloud -n $NAMESPACE --create-namespace -f helm/values.yaml
echo "Done. Verify with: kubectl -n $NAMESPACE get pods"
