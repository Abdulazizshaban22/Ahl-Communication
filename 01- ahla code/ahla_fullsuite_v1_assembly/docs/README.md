# Ahla — FullSuite v1 (Consolidated Delivery)
**Date:** 2025-10-19

هذه النسخة تدمج كل الحزم الأساسية + SFU، مع خطة ترحيل من المشروع القديم (Hero v60) إلى البنية الجديدة.

## المكونات
- apps/web (Next.js 14 App Router + Auth.js v5 + Prisma + S3/MinIO + Mail + Meetings)
- services/chat-ws (WebSocket)
- services/sfu (Ion-SFU JSON-RPC) + services/coturn (CoTURN)
- deploy (docker-compose + nginx WS proxy)
- ENV_TEMPLATES (.env.core.example, .env.sfu.example)
- scripts (أدوات ترحيل وتشغيل)
- docs (خطة ترحيل، ترتيب الملفات، التشغيل)

## تشغيل سريع
1) `docker compose -f deploy/docker-compose.core.yml up -d`
2) داخل `apps/web`: `npm i && npx prisma generate && npx prisma migrate dev --name init && node scripts/seed-admin.js && npm run dev`
3) (اختياري للمكالمات) `docker compose -f deploy/docker-compose.sfu.yml up -d`
4) افتح `http://localhost`

> للديمو: رفع الملفات يعمل بنمط **path-style** لـ MinIO؛ يمكن الانتقال لـ virtual-host عبر `MINIO_DOMAIN`. 

