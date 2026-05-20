
# Migration from in‑cluster PostgreSQL to Amazon RDS

1) Apply Terraform in this v5 bundle to provision RDS (Multi‑AZ) and expose `kubernetes_secret/ahla-system/db-url`.
2) In your app configs (APIs), read DB URL from that secret instead of in‑cluster service.
3) Drain traffic gracefully (Istio/NGINX canary) while app points to RDS.
4) Delete/disable old PostgreSQL Helm release after verifying migrations and data parity.
5) (Optional) Enable RDS Proxy for better connection pooling under high concurrency.
