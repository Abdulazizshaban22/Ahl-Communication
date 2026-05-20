# Ahla v3.9.2 — WAF Bot Control (TARGETED) + Multi‑Service SLO (Composite)

## What you get
- **Global WAF** (CloudFront scope) with **Bot Control (TARGETED)** + **ACFP** + Common.
- **Regional WAF** for **ALB** (association optional).
- **SLO Alarms** per خدمة (Chat/Meet/Drive/Mail) — 1h & 6h burn-rate + composite.
- **Platform-wide composites**:
  - `platform-degraded-any` → أي خدمة تجاوزت SLO.
  - `platform-critical-all` → جميع الخدمات في حالة إنذار.

## Apply (example)
```bash
cd infra/terraform
terraform init
terraform apply   -var="region=eu-central-1"   -var="alb_arn=arn:aws:elasticloadbalancing:eu-central-1:123:loadbalancer/app/ahla/abc"   -var="alb_load_balancer=app/ahla/abc"   -var="alb_tg_chat=targetgroup/ahla-chat/xxx"   -var="alb_tg_meet=targetgroup/ahla-meet/yyy"   -var="alb_tg_drive=targetgroup/ahla-drive/zzz"   -var="alb_tg_mail=targetgroup/ahla-mail/www"   -var="sns_email=ops@ahla.com"
```
> **Note:** For CloudFront, set `web_acl_id = aws_wafv2_web_acl.cf_acl.arn` on your distribution resource (us-east-1 scope).
