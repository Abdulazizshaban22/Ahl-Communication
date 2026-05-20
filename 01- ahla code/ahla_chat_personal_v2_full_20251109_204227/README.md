# Ahla Chat — Personal v2 (Full)

**مكتمل الميزات** بأسلوب واتساب، ويشمل:
- **PWA + Service Worker**: تثبيت على الشاشة الرئيسية + وضع غير متصل + Push.
- **Web Push (VAPID)**: تسجيل الاشتراك وإرسال اختبار عبر خدمة `push-worker`.
- **قفل بالبصمة/FaceID (WebAuthn-lite)**: بوابة محلية (للديمو؛ يفضّل ربطها بخادم WebAuthn).
- **E2EE اختياري** للرسائل + **تشفير مرفقات AES‑GCM** بمفتاح مشتق من سرّ الجلسة.
- **رسائل صوتية** (MediaRecorder) ومرفقات.
- **بحث محلي** + **تصدير نسخة احتياطية** (JSON).
- **مؤشر حدّة النقاش** بسيط عبر `/api/chat/tone`.

## التشغيل المحلي
```bash
cd infra
# (اختياري) توليد مفاتيح VAPID:
# docker run --rm -v $PWD/../services/push-tools:/w -w /w node:20 node generate_vapid.js
# ثم ضع القيم في بيئة docker-compose:
# export VAPID_PUBLIC_KEY=...
# export VAPID_PRIVATE_KEY=...

VAPID_PUBLIC_KEY=${VAPID_PUBLIC_KEY:-""} VAPID_PRIVATE_KEY=${VAPID_PRIVATE_KEY:-""} docker compose up -d --build

# الواجهة:  http://localhost:8089/chat
# API:      http://localhost:8000
# WS:       ws://localhost:8089/ws
# إرسال Push اختبار: POST http://localhost:8787/sendTest  body: { "user":"me" }
```

## مراجع تقنية
- Push API (MDN) & RFCs (8030، 8292 VAPID)، Service Workers، WebAuthn.
- Signal Double Ratchet للمستوى الإنتاجي.