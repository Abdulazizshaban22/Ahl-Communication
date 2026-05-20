# Ahla IaC v4.2 — Realtime HA Patch
Build: 2025-10-20T05:27:39.615197Z

This patch upgrades **v4 / v4.1** with:
1) **CoTURN** – two deployment modes + autoscaling strategy + **AWS NLB (UDP/TCP/TLS)** Service.
2) **NATS JetStream HA (3x)** on EKS with persistent volumes.
3) **Grafana dashboards** for NATS, CoTURN, and **RDS Proxy**.
4) **Terraform for Aurora PostgreSQL** (optional) to replace RDS standard.

> Notes:
> • **HPA does _not_ support DaemonSets** in Kubernetes. We include:
>    - **Deployment + HPA** pattern (classic autoscaling).
>    - **DaemonSet** pattern (one pod per node) — scale by **Cluster Autoscaler** (nodes) and use NLB instance targets.
> • CoTURN exposes **Prometheus metrics** on `/metrics` (since 4.5.x/4.6.x). Enable with `--prometheus` and scrape on port 9641.

## How to apply
Place this folder **next to** your `ahla_iac_v4_helm_eks/` repo, then copy the files you need:
- `k8s/coturn/` (choose mode), `k8s/nats/` (HA StatefulSet), `grafana/dashboards/*.json`.
- `terraform/aurora/` if you want Aurora PostgreSQL.

Then run:
```bash
# Example: apply NATS HA + CoTURN Deployment+HPA
kubectl apply -f k8s/nats/
kubectl apply -f k8s/coturn/deployment-hpa/
# OR use k8s/coturn/daemonset (one-per-node, scale via nodes)
kubectl apply -f k8s/coturn/daemonset/
# Dashboards
kubectl -n monitoring create configmap ahla-dashboards --from-file=grafana/dashboards --dry-run=client -o yaml | kubectl apply -f -
```
