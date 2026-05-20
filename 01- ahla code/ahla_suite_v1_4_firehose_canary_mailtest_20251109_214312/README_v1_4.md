
# Ahla Suite v1.4 — Firehose → OpenSearch + Canary (All Web) + Mail Test

هذه الترقية تضيف:
1) خط تدفق **CloudWatch Logs → Kinesis Firehose → OpenSearch** مع نسخ احتياطي S3.
2) **Canary** عام لكل الواجهات (chat/meet/drive/business/mail) عبر ALB.
3) ملفات اختبار **Ahla Mail** (إرسال عبر SES/استقبال عبر WorkMail).

## كيف تفعلها سريعًا؟
- عدّل `terraform/envs/prod/firehose_opensearch.tf` لو احتجت أسماء Log groups مختلفة.
- `terraform apply` في `envs/prod` بعد تحديث `prod.tfvars`.
- لتبديل أوزان الـCanary غيّر `weight` في `canary_all_web.tf` (مثال: 50/50 → 100/0).

> ملاحظة: `aws_cloudwatch_log_subscription_filter` يسمح بوجهة واحدة لكل Log Group؛ لا تنشئ اشتراكًا آخر لنفس المجموعة.
