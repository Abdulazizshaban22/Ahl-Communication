# Ahla Intelligence Fabric — v1.1.1 PATCH
Adds:
1) **CloudFront + WAF** in front of Orchestrator (public API, protected).
2) **Apdex SLO + Alarms** via CloudWatch (Canary + alarms) and Grafana formula.
3) **AIF ⇄ Apps Topics** (Chat/Meet/Drive/Business) and Orchestrator routes.

Apply against v1.1 PROD package:
- Copy `infra/terraform/*.tf` files into your existing `infra/terraform`.
- Copy `apps/orchestrator/app.topics.patch.py` over `apps/orchestrator/app.py` (or merge).
- `terraform init && terraform apply`

## Notes
- This patch flips ALB to **internet-facing** for CloudFront origin.
- Restricts ALB **security group** to **CloudFront managed prefix list** only + custom header check.
- WAF includes **Core + Bot Control + ATP (login protection)** (requires mapping your login paths).
- Canary monitors `/health` and emits metrics for **Apdex** calculation.
