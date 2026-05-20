# Ahla Env Overlays v1
Build: 2025-10-20T09:33:34.320240Z

تتضمن هذه الحزمة:
- **overlays/staging|prod/**: ملفات قيم Helm خاصة بكل بيئة (خدمات Ultra + تطبيقات Ahla).
- **k8s/cert-manager/**: `ClusterIssuer` لتفعيل Let's Encrypt (staging & prod).
- **k8s/external-dns/**: قيم التشغيل لـ ExternalDNS لكل بيئة.
- **.github/workflows/deploy_env_overlays.yml**: ووركفلو لنشر القيم حسب البيئة.

## الاستخدام
### 1) شهادات TLS عبر cert-manager
طبّق الإصدار المناسب:
```bash
kubectl apply -f k8s/cert-manager/cluster-issuer-staging.yaml   # بيئة اختبار
kubectl apply -f k8s/cert-manager/cluster-issuer-prod.yaml      # بيئة إنتاج
```
ثم حدّد `tlsSecret` في `values.yaml` لكل تشارت — سيُنشىء cert-manager الشهادات تلقائيًا.

### 2) ExternalDNS
عدّل القيم إذا لزم ثم:
```bash
helm upgrade -i external-dns oci://registry-1.docker.io/bitnamicharts/external-dns   -n external-dns --create-namespace -f k8s/external-dns/values-staging.yaml
# أو للإنتاج
helm upgrade -i external-dns oci://registry-1.docker.io/bitnamicharts/external-dns   -n external-dns --create-namespace -f k8s/external-dns/values-prod.yaml
```

### 3) نشر خدمات Ultra/Apps حسب البيئة
- من GitHub Actions: **Deploy Env Overlays** واختَر `staging` أو `prod`.
- أو يدويًا:
```bash
# مثال: نشر asr-service على prod
helm upgrade -i ahla-asr-service charts/ahla-asr-service -n ahla   -f overlays/prod/services/ahla-asr-service.values.yaml   --set image.repository=$ECR_REGISTRY/ahla/ahla-asr-service   --set image.tag=$GIT_SHA
```

> تذكير: يمكن تمرير أكثر من ملف قيم باستخدام `-f` عدة مرات (ملف أساسي + ملف بيئة).
