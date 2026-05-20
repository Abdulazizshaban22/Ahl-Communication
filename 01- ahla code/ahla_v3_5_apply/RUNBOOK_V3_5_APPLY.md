# Runbook — v3.5 APPLY

## 0) قبل البدء
- تأكد من أن v3.4.1 مطبق (WAF الأساسي + CloudFront + PDPL + MFA).
- جهّز قيم `terraform/v3_5.auto.tfvars` (أو دمجها في tfvars الحالي).

## 1) تمكين WAF (Bot Control + ATP)
- طبّق `terraform/waf_bot_atp.tf` (CloudFront association + ALB association).
- تأكد أن login_paths تغطي مسارات الدخول الفعلية.

## 2) إنشاء كناريات Synthetics
- `terraform/synthetics.tf` يرفع `canaries/ahla-canary.zip` ويُنشئ 3 كناريات (chat/meet/drive).
- الوظيفية: فتح الصفحة وقياس زمن التحميل + إخفاق عند محتوى غير كافٍ.

## 3) X-Ray
- أرفق سياسة AWSXRayDaemonWriteAccess إلى دور مهمة ECS.
- أضف Sidecar واسند `AWS_XRAY_DAEMON_ADDRESS` للحاويات.
- تحقق من Trace Map.

## 4) الموبايل
- عبّي `.env.mobile.example` ثم خصّص مفاتيح Push (APNs/FCM/HMS) في Secrets Manager.
- فعّل AppAuth في التطبيقات، واختبر تسجيل الدخول.

## 5) فحوصات ما بعد التطبيق
- CloudFront/ALB WAF metrics: ارتفاع حظر البوتات/محاولات ATO.
- Synthetics: نجاح ≥ 99%، مدة TTFB مستقرة.
- X-Ray: ظهور traces وروابط للخدمات.
- Push: وصول إشعارات iOS/Android/Huawei.

## 6) رجوع سريع
- أزل associations من WAF مؤقتًا إن ضبطت قواعد شديدة.
- أوقف الكناريات إذا أردت تقليل الكلفة.
