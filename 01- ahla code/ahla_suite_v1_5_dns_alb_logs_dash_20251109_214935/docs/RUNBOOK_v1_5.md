
# Ahla v1.5 — Route53 Mail Records + ALB Access Logs → OpenSearch + Dashboards

## DNS (Route53) — WorkMail/SES
- `terraform/envs/prod/route53_mail_records.tf` يحتوي MX/TXT (WorkMail) + CNAMEs لـDKIM + SPF + DMARC.
- احصل على قيم **DKIM selectors** و **TXT verification** من **SES** ثم حدّث الملف.

## ALB Access Logs → OpenSearch
- فعّل access logs على ALB لكتابة ملفات إلى S3 (`alb_logs_firehose.tf` ينشئ الـbucket والسياسة).
- يتم تفعيل **S3 Event → Lambda → Firehose** لإرسال السجلات إلى **OpenSearch** (نفس الـDelivery Stream `logs_to_os`).
- بديل جاهز: استخدم تطبيق **Serverless Application Repository** (alb-logs-firehose-publisher) إن رغبت.

## Grafana/OpenSearch
- استورد Dashboard OpenSearch: `grafana/dashboards/ahla_opensearch_logs.json`
- استورد Dashboard Loki (Dev): `grafana/dashboards/ahla_loki_dev.json`
- أضف Data Source:
  - **OpenSearch**: endpoint من Terraform output (`opensearch_endpoint`)
  - **Loki (Dev)**: http://loki:3100

