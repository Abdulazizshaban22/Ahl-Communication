# Ahla Suite v5 — Go-Live Cloud
**Build:** 2025-10-20T09:44:51.134316Z

هذه الحزمة تجمع كل ما تحتاجه لتشغيل منظومة أهلا (Apps + Ultra AI + Overlays + GitOps).
- انظر مجلد **packs/** للباكات الفرعية (Ultra/Charts/Overlays/ArgoCD).
- استخدم **bootstrap.sh** كبداية سريعة (تنزيل helm/kubectl، ربط EKS، تطبيق issuers).

## المحتويات
- `packs/` — الباقات الفرعية (ملفات ZIP)
- `k8s/` — ملفات cert-manager issuers وExternalDNS (من الأوفِرلايز)
- `bootstrap.sh` — تمهيد الكلاستر والخطوات اللاحقة
- `RUNBOOK.md` — مسار خطوة بخطوة للنشر والمراقبة
- `CHECKLIST.md` — قائمة تحقق سريعة قبل الإنتاج

## المتطلبات
- AWS EKS جاهز، OIDC لـ GitHub Actions، نطاق Route53 (ahla.com)، AWS Load Balancer Controller، cert-manager، ExternalDNS.

## الخطوات العالية
1) حمّل الباقات في `packs/` وافتحها بالترتيب (Ultra → Services Charts → Env Overlays → Argo Apps).
2) طبّق **ClusterIssuers** وExternalDNS.
3) فعّل GitOps عبر ArgoCD (App-of-Apps + ApplicationSet).
4) انشر **IngressGroup** (ALB) ثم CloudFront + WAF.
5) راقب المقاييس في Grafana (p95/RPS/Errors/DER/WER/Recall).

> ملاحظات: بعض النماذج (NLLB/pyannote) تتطلب وزنات منفصلة أو توكن HF؛ ضعها في مسارات الخدمات قبل النشر.
