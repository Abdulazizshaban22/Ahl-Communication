# Ahla App Charts v1
Build: 2025-10-20T09:12:26.926697Z

Helm charts لأربع خدمات (HPA + Ingress/ALB + PDB + ServiceAccount) مع CI/CD إلى Amazon EKS.

## المتطلبات
- AWS Load Balancer Controller، ExternalDNS، cert-manager.
- metrics-server لـ HPA.
- مستودعات ECR: `<ECR_REGISTRY>/ahla/<service>`.

## التشغيل
- عدّل قيم الصور ثم:
```bash
helm upgrade -i ahla-chat charts/ahla-chat-api -n ahla --set image.repository=$ECR_REGISTRY/ahla/ahla-chat-api --set image.tag=v1
```
أو استخدم خطّ أنابيب GitHub Actions `.github/workflows/ship_app_charts.yml`.
