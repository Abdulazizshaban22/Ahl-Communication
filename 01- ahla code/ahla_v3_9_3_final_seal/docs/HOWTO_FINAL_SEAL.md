# Ahla v3.9.3 — Final‑Seal

## 1) Auto Count→Block (WAF)
- Lambda: `waf-count2block` يتفحص قواعد Managed Rule Group داخل الـWeb ACL ويحوّل أي `OverrideAction = COUNT` إلى `None` (تطبّق أفعال المجموعة الافتراضية غالبًا BLOCK).
- فعّل جدولة EventBridge بعد 12–24 ساعة مراقبة (افتراضيًا Disabled لتجنّب الحجب قبل المراجعة).
- المتغيرات: `CF_WEB_ACL_ARN`, `ALB_WEB_ACL_ARN`, `ENABLE_AUTO_BLOCK`.

## 2) ChatOps (Slack)
- **AWS Chatbot** يربط SNS → Slack بدون Webhook يدوي. اضبط: `slack_workspace_id`, `slack_channel_id`.
- التنبيهات تشمل: SLO Composite + Anomaly + Burn-rate.

## 3) Anomaly Detection
- منبّهات CloudWatch على: Latency p95 (ALB) + Apdex (مؤشر الرضا) باستخدام `ANOMALY_DETECTION_BAND`.

## 4) Incident Timeline
- Lambda يشترك في SNS ويكتب سجلات الحوادث في OpenSearch (`ahla-incidents`) لعرضها زمنيًا وتصديرها لاحقًا.
- المصادقة: `iam` (موصى) أو `basic` (للبيئات الخاصة).

## Apply (مثال)
```bash
cd infra/terraform
terraform init
terraform apply   -var="region=eu-central-1"   -var="cf_web_acl_arn=arn:aws:wafv2:us-east-1:123:global/webacl/ahla-cf/WEBACL_ID"   -var="alb_web_acl_arn=arn:aws:wafv2:eu-central-1:123:regional/webacl/ahla-alb/WEBACL_ID"   -var="alb_load_balancer=app/ahla/abc"   -var="alb_tg_chat=targetgroup/ahla-chat/xxx"   -var="alb_tg_meet=targetgroup/ahla-meet/yyy"   -var="alb_tg_drive=targetgroup/ahla-drive/zzz"   -var="alb_tg_mail=targetgroup/ahla-mail/www"   -var="sns_topic_arn=arn:aws:sns:eu-central-1:123:ahla-slo-alerts"   -var="slack_workspace_id=T000000" -var="slack_channel_id=C000000"   -var="opensearch_endpoint=https://your-domain.es.amazonaws.com"
```
