# RUNBOOK — Ahla Suite v5

## 0) ربط الكلاستر
- `aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION`

## 1) TLS — cert-manager (ACME HTTP-01)
- `kubectl apply -f k8s/cert-manager/cluster-issuer-staging.yaml`
- `kubectl apply -f k8s/cert-manager/cluster-issuer-prod.yaml`

## 2) DNS — ExternalDNS (Route53)
- نشر ExternalDNS بقيم البيئة (staging/prod) وربط IAM.

## 3) GitOps — ArgoCD
- تطبيق: `argocd/projects/ahla-project.yaml` + `argocd/appsets/*.yaml` + `argocd/apps/root-app.yaml` من حزمة Argo.
- تأكد من تفعيل Auto-Sync + SelfHeal.

## 4) IngressGroup — ALB
- نشر تشارت `ahla-shared-ingress` (group.name ثابت لكل البوابات).

## 5) CDN + WAF
- أنشئ CloudFront عبر `cloudfront/cloudformation-alb-origin.json` واضبط ترويسة سرية للأصل.
- اربط WAFv2 Web ACL (Rate-based) بالـ ALB أو CloudFront.

## 6) مراقبة
- استورد لوحة Grafana من Ultra Pack.
- PromQL p95 (مثال):
  `histogram_quantile(0.95, sum(rate(asr_request_seconds_bucket[5m])) by (le))`

## 7) الذكاء
- ارفع وزنات NLLB بصيغة CTranslate2 إلى مجلد `models/` للخدمة.
- وفّر HF_TOKEN لـ pyannote في البيئة.
- اربط Postgres/pgvector وفعّل HNSW/IVFFlat حسب الأحجام.

## 8) الأمان
- راجع سياسات SSO (Keycloak/OIDC)، تشفير E2EE، سياسات الخصوصية والتعلّم الاتحادي.
