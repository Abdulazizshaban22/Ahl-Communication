
# Ahla Suite v1.7 — Geo-IP Enrichment + SLO Dashboards + Promote 100/0

## 1) Geo-IP Enrichment (OpenSearch ip2geo)
- Pipeline: `opensearch/pipelines/ahla-ip2geo.json`
- Index Template (default_pipeline + mappings): `opensearch/templates/ahla-template.json`
- Apply:
```bash
export OS_ENDPOINT="https://<domain>" OS_USER="admin" OS_PASS="***"
bash scripts/apply_ip2geo.sh
```
> يتطلب OpenSearch 2.10+ مع **ip2geo** وبيانات GeoLite2 عبر endpoint الرسمي.

## 2) SLO & Apdex Dashboards (Grafana)
- استورد `grafana/dashboards/ahla_slo_apdex.json`
- عدّل متغيّر **T** (ثانية) لتعريف آلية Apdex:
  - score = (Satisfied + 0.5 * Tolerating) / Total

## 3) Alerts (OpenSearch → SNS)
- أنشئ **Channel → Amazon SNS** من OpenSearch Dashboards.
- حرّر `opensearch/monitors/*_monitor.json` واستبدل `destination_id`.
- أنشئ Monitorين:
  - 5xx spike آخر 5 دقائق
  - p95 latency > threshold آخر 15 دقيقة

## 4) Promote Canary إلى 100/0
- الملف: `terraform/envs/prod/canary_all_web.tf` (الأخضر=100/الأزرق=0)
- طبّق:
```bash
cd terraform/envs/prod
terraform apply -var-file="prod.tfvars" -auto-approve
```
