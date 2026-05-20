# ترقية منظومة أهلا — Patch v3.0 (مخصص للمستودع الحالي)

هذه الحزمة تبني على الموجود في مجلد **ahla_suite_v1** وتوفّر:
1) **تشغيل إنتاج** على AWS (Terraform + ECR + ECS/Fargate + CloudFront/WAF).
2) **SSO وهوية مؤسسية** (Keycloak Realm جاهز: Ahla Realm).
3) **أمن وامتثال PDPL** (سجلات موافقات/طلبات DSR + سياسة احتفاظ).
4) **مراقبة واعتمادية**: Canary + إنذار Apdex + 5xx (CloudWatch) + لوحات Grafana.
5) **CI/CD**: GitHub Actions لبناء صور (web/api) ودفعها إلى ECR.

## ماذا اكتشفنا في المستودع
- موجود: chat/mail/drive/business كخدمات **Python FastAPI**، و **meet-signaling** (Node/WebSocket)، و **NATS + Redis + MinIO + Keycloak** للتجارب المحلية عبر docker-compose.
- فجوات: غياب E2EE فعلي في Chat/Meet، عدم وجود ربط إنتاج بـ S3/SES/Route53، لا يوجد Terraform مكمّل للكائنات الحالية، غياب PDPL flows، لا يوجد CI/CD موحّد.

## ما تضيفه الحزمة
- **infra/terraform/**: بنية سحابية جاهزة (VPC, RDS, ECS, ALB+CloudFront, WAF, Canary).
- **identity/ahla-realm.json**: تعريف Realm وClients وأدوار أساسية.
- **ops/compose.prod.override.yml**: ضبط موارد/متغيرات إنتاج وربط الصور من ECR.
- **.github/workflows/build-deploy.yml**: بايبلاين يبني صور (web/api) ويدفعها إلى ECR ثم يشغّل `terraform apply`.
- **pdpl/**: سياسات السجلات ومخطط DSR (نموذج API).
- **nginx/nginx.security.conf**: رؤوس أمان (HSTS/CSP) كتحسين على الموجود.

> ملاحظة: نُبقي **NATS** للاستخدام المحلي/التطوير، ونُفضّل **MSK** للإنتاج. يمكنك الإبقاء على NATS في الإنتاج أيضًا—لكنّ MSK يمنحك قابلية توسّع ومراقبة أعلى.
