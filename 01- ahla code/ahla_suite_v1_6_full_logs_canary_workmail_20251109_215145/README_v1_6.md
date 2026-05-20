
# Ahla Suite v1.6 — Full CloudWatch→OpenSearch (ALB/S3) + Canary 50/50 + WorkMail Users

## ما الجديد؟
1) **تفعيل Access Logs على ALB** مباشرة من وحدة الـALB (Terraform module) مع تمرير الـBucket.
2) **مسار كامل لسجلات ALB**: S3 → Lambda (Parser) → Firehose → OpenSearch.
3) **Canary** لجميع الواجهات عند **50/50**.
4) **Provisioning مستخدمي WorkMail** (CLI) من ملف JSON.

## خطوات سريعة
- مرّر `access_logs_bucket = module.alb_logs.alb_logs_bucket_name` عند استدعاء module `alb`.
- طبّق `terraform apply -var-file="prod.tfvars"`.
- استورد لوحات Grafana:
  - `grafana/dashboards/ahla_opensearch_geo_latency.json`
  - (من الإصدارات السابقة) `ahla_opensearch_logs.json` و `ahla_loki_dev.json`
- لتفعيل مستخدمي WorkMail:
  ```bash
  bash scripts/workmail_provision.sh scripts/workmail_users.json
  ```
