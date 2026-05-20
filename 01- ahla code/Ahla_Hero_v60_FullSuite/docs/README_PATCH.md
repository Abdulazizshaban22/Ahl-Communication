# Ahla — Patch Pack v1 (Core Packages)

هذه الحزمة تحتوي ملفات جاهزة لإكمال النسخة التشغيلية الأساسية:
- Auth.js v5 (Credentials) + Prisma Adapter
- Prisma Schema + Seed
- S3/MinIO رفع الملفات
- SMTP Mail
- Meetings API
- WebSocket Chat service
- docker-compose + nginx (WS proxy)
- ONLYOFFICE تمهيد (JWT)

## خطوات مختصرة
1) انسخ `ENV_TEMPLATES/.env.example` إلى جذر مشروعك `.env` وعدّل القيم.
2) شغّل الخدمات الأساسية: `docker compose -f deploy/docker-compose.yml up -d db redis minio onlyoffice chat-ws nginx`
3) داخل `apps/web`:
   - `npm i` ثم ثبّت الاعتمادات المذكورة في `README_DEPENDENCIES.md`
   - `npx prisma generate`
   - `npx prisma migrate dev --name init`
   - `node scripts/seed-admin.js`
   - `npm run dev`
4) اختبارات سريعة:
   - تسجيل الدخول (Admin من الـ .env)
   - رفع ملف عبر signed-url
   - إرسال بريد عبر `/api/mail/send`
   - إنشاء اجتماع عبر `/api/meetings/create`
   - الدردشة عبر `/ws/chat`

> ملاحظة: الاستيراد يستخدم alias `@/lib/...`. إذا لم تكن مهيأً في مشروعك، عدّل الاستيراد لمسارات نسبية.
