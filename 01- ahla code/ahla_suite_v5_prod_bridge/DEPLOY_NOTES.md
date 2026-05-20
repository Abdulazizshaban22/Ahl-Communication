# ملاحظات نشر سريعة
- تأكد من وجود ClusterIssuer ل Let's Encrypt وإعداد HTTP-01 لـ ingress-nginx.
- تأكد أن ExternalDNS مكرر لنطاقات التطبيقات (notes/book/.../api). 
- سر قاعدة البيانات `db-url` يجب أن يكون موجودًا في `ahla-system` (تم إنشاؤه بالحِزم السابقة).
- يفضّل استخدام IRSA للأذونات (ExternalDNS/Controllers).

Troubleshooting:
- cert-manager: تحقق من Issuer/ClusterIssuer والأنوتيشن على Ingress.
- Keycloak: issuer يجب أن يحتوي realm في URL (…/realms/ahla).
