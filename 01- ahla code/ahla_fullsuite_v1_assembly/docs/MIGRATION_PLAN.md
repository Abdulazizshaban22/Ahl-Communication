# خطة الترحيل من Hero v60 إلى FullSuite v1

## 1) الملفات التي تستبدَل مباشرة
- apps/web/server.js → **تم حذف الحاجة له** (App Router + Route Handlers).
- app/api/* الناقصة → **استبدلت** بواجهات كاملة: auth, drive/signed-url, mail/send, meetings/create.
- more/onlyoffice/* → **تمهيد JWT** في .env + lib/onlyoffice (إن رغبت بالموصل لاحقًا).
- services/* (chat/signal) → إبقاء chat-ws، وإضافة حزمة **SFU + CoTURN** منفصلة.

## 2) مطابقة المسارات القديمة للجديدة
- Ahla_Hero_v60_FullSuite/apps/web/app/mail → apps/web/app (واجهاتك تحتفظ بها، أضف صفحاتك هنا).
- Ahla_Hero_v60_FullSuite/apps/web/app/drive → apps/web/app/api/drive/* (للـ API) + واجهات العرض التي لديك.
- Ahla_Hero_v60_FullSuite/apps/web/app/chatmail → apps/web/app (صفحات محادثة) + services/chat-ws
- Ahla_Hero_v60_FullSuite/services/signaling-server → استبدله بـ sfu (Ion-SFU) + coturn.
- deploy/docker-compose.yml القديم → split إلى docker-compose.core.yml و docker-compose.sfu.yml.

## 3) قاعدة البيانات
- استخدم schema.prisma الجديد، ثم شغّل الهجرات؛ إن كان لديك جداول قديمة، أنشئ **مهاجرات تحويل** يدوية (ALTER TABLE/RENAME) قبل تشغيل `migrate deploy` للإنتاج.

## 4) المصادقة
- توحيد على **Auth.js v5** (Route Handlers) بدل حلول مخصصة.

## 5) التخزين
- الربط مع MinIO عبر AWS SDK v3 مع `forcePathStyle=true`. التحويل إلى virtual-host لاحقًا ممكن عبر `MINIO_DOMAIN`.

