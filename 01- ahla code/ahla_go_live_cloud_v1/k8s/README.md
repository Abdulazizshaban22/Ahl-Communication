# Ahla Go-Live Cloud — Kubernetes/Helm
Build: 2025-10-20T09:04:47.839490Z

## المتطلبات على الكلاستر
- AWS Load Balancer Controller + OIDC/IRSA
- ExternalDNS (Route53)
- cert-manager (ACME HTTP-01)
- NATS (JetStream + WebSocket)
- CoTURN (443/TLS)
- MinIO أو S3
- kube-prometheus-stack (Grafana/Prometheus/Loki/Tempo)

## أوامر قياسية (Helm)
```bash
# 1) cert-manager
helm repo add jetstack https://charts.jetstack.io
helm upgrade -i cert-manager jetstack/cert-manager -n cert-manager --create-namespace   --set crds.enabled=true

# 2) AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system   --set clusterName=$(aws eks list-clusters --query 'clusters[0]' --output text)

# 3) ExternalDNS
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm upgrade -i external-dns external-dns/external-dns -n external-dns --create-namespace   -f external-dns-values.yaml

# 4) NATS
helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm upgrade -i nats nats/nats -n messaging --create-namespace -f nats-values.yaml

# 5) CoTURN
helm upgrade -i coturn oci://ghcr.io/coturn/coturn-chart -n rtc --create-namespace -f coturn-values.yaml

# 6) MinIO (أو استخدم S3)
helm repo add minio https://charts.min.io/
helm upgrade -i minio minio/minio -n storage --create-namespace -f minio-values.yaml

# 7) kube-prometheus-stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade -i monitoring prometheus-community/kube-prometheus-stack -n monitoring   --create-namespace -f grafana-stack-values.yaml
```

> أنشئ **ClusterIssuer** لـ ACME وأضف Ingress لكل خدمة تريدها عبر ALB/NLB حسب البروتوكول.
