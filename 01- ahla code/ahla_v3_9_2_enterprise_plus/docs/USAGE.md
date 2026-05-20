# Ahla v3.9.2 — الاستخدام السريع

1) Terraform
```bash
cd infra/terraform
terraform init
terraform apply   -var="region=eu-central-1"   -var="alb_arn=arn:aws:elasticloadbalancing:eu-central-1:123:loadbalancer/app/ahla/abc"   -var="alb_load_balancer=app/ahla/abc"   -var="alb_tg_chat=targetgroup/ahla-chat/xxx"   -var="alb_tg_meet=targetgroup/ahla-meet/yyy"   -var="alb_tg_drive=targetgroup/ahla-drive/zzz"   -var="alb_tg_mail=targetgroup/ahla-mail/www"   -var="sns_email=ops@ahla.com"
```

2) Grafana
- استورد `grafana/dashboards/ahla_unified_slo.json` لعرض Apdex + Burn-rate + Latency + حالة Composite.

3) توصيات
- فعّل وضع **Count** في WAF لبضع ساعات ثم راقب **False Positives** قبل التحويل إلى **Block**.
- اضبط عتبات Apdex لكل خدمة حسب T (مثلاً Chat 200ms، Meet 250ms).
