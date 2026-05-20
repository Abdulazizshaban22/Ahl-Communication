# Ahla Chat v3.1 — Push + Presets + Whisper-ready + Encrypted Backups

يشمل:
- (أ) **Web Push متكامل (VAPID)** + فتح غرفة معيّنة عند الضغط على الإشعار.
- (ب) **Presets للترميز** عبر MediaRecorder مع تفضيلات (AV1/VP9/H.264)، والتهيئة لاحقًا لدعم WebCodecs.
- (ج) **تفريغ صوت محلي (whisper.cpp — WASM)** واجهة عمل جاهزة (ضع ملفات wasm/model في `apps/chat-web/public/whisper/`).
- (د) **نسخ احتياطية مشفّرة** بكلمة مرور (PBKDF2 + AES‑GCM) + صفحات Safety Number/Settings/Backup.

## التشغيل المحلي
```bash
cd infra
# توليد مفاتيح VAPID (اختياري):
# docker run --rm -v $PWD/../services/push-tools:/w -w /w node:20 node generate_vapid.js
# export VAPID_PUBLIC_KEY=...
# export VAPID_PRIVATE_KEY=...

VAPID_PUBLIC_KEY=${VAPID_PUBLIC_KEY:-""} VAPID_PRIVATE_KEY=${VAPID_PRIVATE_KEY:-""} docker compose up -d --build

# الواجهة:         http://localhost:8093/chat
# إرسال Push:      POST http://localhost:8787/sendTo   JSON: { "user":"me","room":"personal","body":"Hello" }
# Moments API:     http://localhost:8010/health
# Emotion API:     http://localhost:8020/health
```

> لتمكين whisper على الجهاز: ضع ملفات `whisper.js/whisper.wasm/ggml-tiny.bin` في `apps/chat-web/public/whisper/` ثم عدّل worker حسب واجهة بناءك.