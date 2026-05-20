# Ahla v7.9 — Tech Luxury Edition (WhatsApp-style)

واجهة بسيطة مثل واتساب، بذكاء سيادي كامل. هذه النسخة تحتوي:
- **apps/web** (Next.js 14 + Tailwind) — واجهة دردشة فاخرة وبسيطة
- **services/chat-ws** (WebSocket + Prometheus metrics)
- **services/chat-api** (FastAPI + Redis + /metrics)
- **services/emotion-engine** (تحليل مشاعر بسيط مع /metrics)
- **infra** (Nginx reverse proxy + Prometheus + Grafana + Redis + Compose)

> شغّل كل شيء محليًا خلال دقائق.

## المتطلبات
- Docker + Docker Compose
- منافذ متاحة: 8088 (الواجهة)، 8080 (WS)، 8000 (API)، 8010 (Emotion)، 9090 (Prometheus)، 3001 (Grafana)

## التشغيل السريع
```bash
cp .env.example .env
cd infra
docker compose up -d --build
# الواجهة: http://localhost:${ '8088' }
# Grafana: http://localhost:3001  (admin / admin)
# Prometheus: http://localhost:9090
```

## كيف تعمل؟
- **الويب** يتصل بـ **/ws** (WebSocket) عبر الوكيل **Nginx** لإرسال/استقبال الرسائل.
- **chat-api** يخزن آخر 500 رسالة لكل غرفة داخل **Redis**، ويقدم **/suggest** لاقتراحات الردود.
- **emotion-engine** يوفّر تحليل مشاعر بسيط (نموذج قابل للاستبدال لاحقًا بـ ONNX).
- **Prometheus/Grafana** تلتقط مقاييس الخدمات من مسارات **/metrics**.

## PDPL (السعودية)
- هذه النسخة توفر **نقاط ربط الامتثال**: صفحة سياسة خصوصية، وإطار DSR (مجلد `pdpl/`).
- قبل الإنتاج، راجع دليل SDAIA PDPL لتفعيل: تسجيل المعالجة، سياسة الخصوصية، طلبات النفاذ/المحو، وضبط الحفظ.

## استبدال الذكاء بنموذج حقيقي
- ضع نموذج ONNX أو موصل OpenAI/LLM داخل `services/emotion-engine` وحدث `/analyze`.
- أضف `pgvector/Meilisearch` لبحث دلالي متقدم (اختياري).

## ملاحظات
- Nginx مهيأ لعبور WebSockets (`/ws`) والتوجيه إلى API وEmotion.
- تم تضمين مقاييس Prometheus في الخدمات.
