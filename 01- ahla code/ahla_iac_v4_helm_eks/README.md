# Ahla IaC v4 — Helm + Terraform (AWS EKS)
Build: 2025-10-20T05:18:47.769350Z

This bundle provisions an **EKS cluster** (VPC + NodeGroups) and deploys the **Ahla platform** with Helm:
- cert-manager (ACME HTTP-01), ingress-nginx, external-dns (Route53)
- kube-prometheus-stack (Prometheus/Grafana/Alertmanager)
- NATS (JetStream-ready), PostgreSQL (Bitnami), MinIO (Bitnami)
- Mobile WS Gateway Helm chart (JSON↔NATS) + sample values
- ClusterIssuer for Let's Encrypt (HTTP-01)
- Optional Istio canary (can be added later)

## Quick Start
1) `cd terraform` → set variables in `terraform.tfvars` (region, domain, hosted_zone_id).
2) `terraform init && terraform apply` (creates VPC + EKS and installs Helm charts).
3) Import Grafana dashboards from `grafana/dashboards/*.json` (optional).
4) `helm upgrade --install ahla-platform charts/ahla-platform -f charts/ahla-platform/values.yaml` (installs Ahla umbrella + mobile-gateway).
