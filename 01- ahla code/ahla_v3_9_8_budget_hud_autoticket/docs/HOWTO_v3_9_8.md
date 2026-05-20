# Ahla v3.9.8 — SLO Budget HUD + Auto‑Ticket + Silence Sync

## 1) SLO Budget HUD (Grafana)
- لوحة `grafana/dashboards/slo_budget_hud.json` تبيّن:
  - **Error Budget Remaining** = `max(0, 1 - BurnRate_30d)`
  - **Projected Exhaustion (days)** = `(Remaining * 30) / BurnRate_1h`
- نوافذ الحساب: 30 يوم للميزانية، ونافذة ساعة لتوقّع الاستنزاف.
- عدّل أهداف SLO حسب خدمتك (0.999 / 0.995).

## 2) Auto‑Ticket (SNS → Lambda → Jira/Slack/Notion)
- اشترك منبّهات CloudWatch/SLO على موضوع SNS الممرّر إلى Lambda `auto-ticket`:
  - ينشئ تذكرة Incident في **Jira**،
  - يرسل إشعارًا إلى **Slack webhook** (احتياطيًا إن لم تستخدم AWS Chatbot)،
  - يسجّل بطاقة في **Notion** (اختياري).
- المتغيرات: `JIRA_URL, JIRA_EMAIL, JIRA_API_TOKEN, JIRA_PROJECT_KEY, SLACK_WEBHOOK, NOTION_*`.

## 3) Silence Sync (GitOps)
- Lambda `silence-sync` تقرأ ملف YAML من Git/S3 لتوليد **Silences** في Grafana Alerting API،
- يمكن جدولتها عبر `silence_sync_cron` (EventBridge).

## 4) نشر سريع
```bash
cd infra/terraform
terraform init && terraform apply   -var="region=<aws-region>"   -var="name_prefix=ahla"   -var="jira_url=https://<org>.atlassian.net"   -var="jira_email=<you@domain>"   -var="jira_api_token=<token>"   -var="jira_project_key=OPS"   -var="slack_webhook=https://hooks.slack.com/services/..."   -var="grafana_url=https://grafana.example.com"   -var="grafana_token=<grafana-api-token>"   -var="git_silence_url=https://raw.githubusercontent.com/<repo>/silences.yaml"
```

## 5) ملاحظات
- إن كنت تستخدم **AWS Chatbot** لربط SNS→Slack، يمكنك ترك `SLACK_WEBHOOK` فارغًا.
- تأكد من تفعيل مقاييس `Ahla/<SERVICE>/Requests|Errors` في CloudWatch.
