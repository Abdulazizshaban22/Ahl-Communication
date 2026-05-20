# Ahla Argo Apps v1
Build: 2025-10-20T09:39:06.954727Z

يتضمن:
- **argocd/**: AppProject + ApplicationSet (Ultra services + App services) + Root App-of-Apps.
- **charts/ahla-shared-ingress/**: إنجريس موحّد باستخدام **ALB IngressGroup**، مع خيار ربط **AWS WAFv2**.
- **overlays/staging|prod/apps/**: قيم لكل تطبيق واجهة (تعطيل إنجريس الداخلي، ترويسات Cache-Control، مضيف عام).
- **cloudfront/**: قالب CloudFormation يضع **CloudFront** أمام **ALB** مع ترويسة سرية لمنع الوصول المباشر.

## الاستخدام
1) طبّق `argocd/projects/ahla-project.yaml` ثم `argocd/appsets/*.yaml` و `argocd/apps/root-app.yaml`.
2) انشر تشارت `charts/ahla-shared-ingress` بنفس **group.name** لكل خدمات الواجهة.
3) مرّر ARN الخاص بـ **WAFv2** عبر قيمة `wafv2AclArn` لتفعيل معدل-مبني (Rate-based) في WAF.
4) استخدم `cloudfront/cloudformation-alb-origin.json` لإنشاء توزيع CloudFront مع ترويسة منشأ سرية.

> تلميحات:
> - يدعم **ALB WebSocket** تلقائيًا (WS/WSS)؛ فقط تأكد من السماح بالترقية. 
> - استخدم ExternalDNS وcert-manager كما في الحزم السابقة.
