# Ahla Cloud v1 — Go‑Live Pack
Build: 2025-10-20T06:00:03.223142Z

هذه الحزمة تُجهّز انطلاق الإنتاج على **AWS EKS** (Helm + Terraform) مع TLS/ACME وDNS تلقائيين،
NATS JetStream HA، CoTURN على 443/TLS، KEDA Autoscaling، Observability، وBackups.

## المحتويات
- `helm/` : تشارتات جاهزة (umbrella) + موارد مساعدة (ClusterIssuer، CoTURN/NLB، JetStream، KEDA، Dashboards).
- `terraform/` : عينات Aurora PostgreSQL + S3 للنسخ الاحتياطي + IAM (IRSA) لـ ExternalDNS.
- `ops/` : سكربتات QuickStart + سياسات حوكمة/Retention + نماذج تنبيه Grafana.

## الترتيب السريع
```bash
# (1) قيّم القيم
cp helm/values.example.yaml helm/values.yaml

# (2) نشر المراقبة أولًا (اختياري إذا لديك stack سابق)
helm upgrade --install monitoring helm/monitoring -n monitoring --create-namespace

# (3) نشر البنية الأساسية (cert-manager/issuer, external-dns hints, nats, coturn, keda)
helm upgrade --install ahla-cloud helm/ahla-cloud -n ahla-system --create-namespace -f helm/values.yaml

# (4) نشر التطبيقات (أو استعمل حزمة Prod Bridge السابقة)
helm upgrade --install ahla-suite ./helm/ahla-suite -n ahla-system -f helm/values.yaml
```
> غيّر الصور/النطاقات/الأسرار في `values.yaml` قبل النشر.
