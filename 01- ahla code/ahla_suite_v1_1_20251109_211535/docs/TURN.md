
# TURN/NAT Traversal
- NLB (UDP/TCP 3478) يوجه إلى خدمة coturn في ECS.
- في الواجهة `meet-web`، يتم جلب تكوين STUN/TURN من `/api/meet/ice`.
- في الإنتاج: أنشئ سجل `turn.SUBDOMAIN` تلقائيًا ضمن Terraform.

لأمان أقوى: استخدم `static-auth-secret` في coturn لتوليد كلمات مرور مؤقتة (TODO).
