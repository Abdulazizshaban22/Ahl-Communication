# Migration: In‑cluster PostgreSQL → Amazon RDS

1) Apply Terraform (this patch) to provision RDS and create secret `ahla-system/db-url`.
2) Flip your APIs to use `DATABASE_URL` from that secret.
3) Validate reads/writes, migrations, and background jobs.
4) Disable the old Helm PostgreSQL release from v4, for example:
   ```bash
   helm -n ahla-system uninstall postgresql
   ```
5) Optional: enable **RDS Proxy** for pooling on high concurrency.
