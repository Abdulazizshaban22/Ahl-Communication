# Ahla Ultra Services Charts v1
Build: 2025-10-20T09:30:43.313745Z

Helm charts جاهزة + CI/CD لخدمات Ultra الأربع: ASR / Translate / Diarization / Search.

## لماذا هذا التصميم؟
- **Labels/Annotations** وفق Best Practices من Helm وKubernetes. راجع مراجعنا. 
- **HPA autoscaling (autoscaling/v2)** وفق دليل Kubernetes.
- **Ingress (ALB)** مع تعليقات AWS Load Balancer Controller.
- **ServiceMonitor** من Prometheus Operator لالتقاط `/metrics` تلقائيًا.
- **TLS ACME HTTP-01** عبر cert-manager لربط الشهادات.

## استخدام سريع
1) اربط أسرار GitHub: `AWS_REGION`, `EKS_CLUSTER_NAME`, `AWS_ROLE_TO_ASSUME`, `ECR_REGISTRY`.
2) استبدل Dockerfile.<service> بملفك الفعلي.
3) ادفع إلى branch `main`، وسيبني ويدفع وينشر تلقائيًا.
4) استورد لوحة Grafana من حزمة Ultra (إن احتجت قياس p95).

> تذكير: تحتاج Prometheus Operator أو kube-prometheus-stack لقراءة `ServiceMonitor`.
