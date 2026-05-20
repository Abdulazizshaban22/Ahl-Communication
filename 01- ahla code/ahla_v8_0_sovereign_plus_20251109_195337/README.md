# Ahla v8.0 — Sovereign+ Tech Luxury (WhatsApp-style)

هذه النسخة تضيف:
- **E2EE اختياري على الواجهة** (AES-GCM client-side؛ لا تُخزّن المفاتيح على الخادم)
- **JWT Auth (اختياري)** للـAPI (تحقق عبر مفتاح عام أو Dev mode)
- **Meilisearch** لفهرسة الرسائل والبحث الفوري
- **Emotion Engine** مع خيار ONNX Runtime
- **Grafana Dashboard** مُضمّنة
- **Nginx Reverse Proxy** و **Prometheus** و **Redis**

## التشغيل السريع
```bash
cp .env.example .env
cd infra
docker compose up -d --build
# Web:       http://localhost:${ '8088' }
# Grafana:   http://localhost:3001  (admin/admin)
# Prometheus:http://localhost:9090
# Meili:     http://localhost:7700 (X-Meili-API-Key: MEILI_KEY)
```

## الوضع الخاص E2EE
- من شاشة الدردشة اضغط **"تفعيل الخاص 🔐"** — يولِّد مفتاحًا سريًا محليًا ويخزّنه في LocalStorage.
- تُرسل الرسائل مُشفّرة (لا تُعرض نصًا في الخادم، وتُفهرس فقط الرسائل غير المشفرة).
> **تحذير:** هذا نموذج مرجعي. للإنتاج نوصي بمفاتيح لكل محادثة + تبادل مفاتيح آمن (X25519) وإدارة سياسات فقدان المفتاح.

## المصادقة JWT
- ضع `JWT_PUBLIC_KEY` و`JWT_AUD/ISS` لإجبار تحقق التوكين؛ أو اترك `JWT_OPTIONAL=true` للتطوير.

## البحث
- الرسائل غير المشفرة تُفهرس تلقائيًا في Meilisearch (index: `messages`).
- لتعبئة سابقة: 
```bash
docker compose run --rm indexer
```

## ONNX
- ضع نموذجك في `emotion-engine:/models/model.onnx` وفعل `USE_ONNX=true`.

## PDPL
- راجع `pdpl/` للسياسة وإجراءات DSR. فعّل سجلات الولوج وحذف البيانات قبل الإنتاج.

## المراقبة
- `/metrics` متاحة لـ chat-ws و chat-api و emotion-engine.
- لوحة Grafana جاهزة: **Ahla — Realtime**.
