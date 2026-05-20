# Ahla v9.2 — Go‑Live AWS + SSO (NextAuth + Keycloak)

هذه الحزمة تضيف:
- **SSO كامل للواجهات** (NextAuth v5 + Keycloak) في `apps/omni-web` و`apps/business-web` مع حماية Middleware.
- **Terraform AWS**: VPC + ECR + IAM + ALB + ECS (خدمة reverse-proxy كنقطة دخول).
- **Workflow GitHub Actions** لبناء ودفع صورة `reverse-proxy` إلى ECR.

## الدمج مع v9.1
انسخ مجلد `apps/` إلى مشروع v9.1 ليتم تفعيل SSO للتطبيقين.  
ثم استخدم `infra/terraform` لنشر واجهة الدخول على ECS/ALB.

## الخطوات
1) إعداد ECR عبر GitHub Actions (تعيين أسرار AWS في الريبو).
2) تحديث `infra/terraform/env/terraform.tfvars`.
3) تشغيل `scripts/deploy_aws.sh`.
4) ضبط الـ DNS لـ `domain_name` إلى `alb_dns` الناتج من Terraform.
5) تفعيل HTTPS عبر ACM (مرجع `certificate_arn`).

> ملاحظة: هذا Blueprint للتشغيل السريع. أضف بقية الخدمات كتاسكات ECS إضافية أو انقل حزمة Docker Compose عبر ECS Compose/EC2 حسب ما تفضّل.