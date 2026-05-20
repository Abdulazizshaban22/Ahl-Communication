# Ahla v3.9.6 — SLO Burn‑Rate Alerts + ChatOps

## ما الذي أضفناه؟
- **قواعد إنذار Burn‑Rate متعددة النوافذ (Multi‑window, Multi‑burn‑rate)** وفق نمط Google SRE:
  - Fast: **5m & 1h** بحد **14.4** (≈ 2% ميزانية الخطأ/ساعة لــ 30 يوم).
  - Medium: **30m & 6h** بحد **6** (≈ 5%/6 ساعات).
  - Slow: **6h & 3d** بحد **1** (≈ 10%/3 أيام).
- **Composite Alarms** تجمع زوج النوافذ بـ AND لخفض الضجيج، + منبه **Platform Degraded (ANY)**.
- **ChatOps Slack (AWS Chatbot)**: ربط SNS بقناة Slack للتنبيهات الفورية.

## افتراض المقاييس
لكل خدمة (Chat/Meet/Drive/Mail) عندك مقاييس CloudWatch:
- `Namespace: Ahla/<SERVICE>`
  - `Requests (Sum)` — عدد الطلبات.
  - `Errors (Sum)` — عدد الأخطاء (5xx/4xx حسب تعريفك).

## معادلة الحرق
**Burn Rate = (Errors / Requests) / (1 - SLO_target)**  
حيث `1 - SLO_target` هو **ميزانية الخطأ**.

## التشغيل السريع
```bash
cd infra/terraform
terraform init
terraform apply   -var="region=eu-central-1"   -var="name_prefix=ahla"   -var="metric_ns=Ahla"   -var="slack_team_id=TXXXX" -var="slack_channel_id=CXXXX"   -var="chatops_iam_role_arn=arn:aws:iam::123:role/ChatOpsRole"
```
> ملاحظة: لو عندك SNS سابق، مرّر `-var="sns_topic_arn=arn:aws:sns:...:ahla-slo-alerts"`.

## تشغيل ChatOps
- يربط Terraform قناة Slack عبر **AWS Chatbot** تلقائيًا؛ كل Composite/Metric alarm يرسل إلى SNS → Slack.

## لماذا هذا النمط؟
- يقلل الإنذارات الكاذبة، ويبلغك بسرعة، ويغلق الإنذار أسرع بعد الإصلاح لأن نافذة قصيرة تعود إلى الأخضر سريعًا.
