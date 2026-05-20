#!/usr/bin/env bash
set -euo pipefail
NAMESPACE="ahla-system"
helm uninstall ahla-suite -n ${NAMESPACE} || true
helm uninstall ahla-cloud -n ${NAMESPACE} || true
helm uninstall kube-prometheus-stack -n monitoring || true
helm uninstall external-dns -n external-dns || true
helm uninstall ingress-nginx -n ingress-nginx || true
helm uninstall cert-manager -n cert-manager || true
kubectl delete ns ${NAMESPACE} monitoring external-dns ingress-nginx cert-manager --ignore-not-found
echo "🗑️ Cluster resources removed (namespaces may take time to terminate)."
