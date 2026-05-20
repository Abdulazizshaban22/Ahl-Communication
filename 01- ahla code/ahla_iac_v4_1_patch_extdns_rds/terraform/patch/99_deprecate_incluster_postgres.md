# Deprecation: In‑cluster PostgreSQL
- Remove or disable the Bitnami PostgreSQL Helm release from v4 after apps flip to RDS:
  ```bash
  helm -n ahla-system ls | grep postgresql
  helm -n ahla-system uninstall postgresql
  ```
- Keep MinIO and NATS as‑is; only the DB moves to RDS.
