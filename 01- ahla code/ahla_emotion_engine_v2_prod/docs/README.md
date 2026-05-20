# Ahla Emotion Engine v2 — Production Autotrain
Build date: 2025-10-19

## ما الجديد؟
- تشغيل إنتاجي عبر **Gunicorn + Uvicorn workers** (تحجيم أفقي).
- **OpenTelemetry** مدمج للقياس والمراقبة.
- **Autotrain** عبر **Prefect + GitHub Actions** + تسجيل النماذج في **MLflow**.
- **مراقبة الانجراف** (Evidently) مع تقرير HTML.
- **استدلال على الجهاز** (ONNX Runtime Web) اختياري للخصوصية.
- **تعلم اتحادي** (Flower) — هيكل جاهز لتفعيل التدريب على الأجهزة.

## خطوات التشغيل السريعة
1) خادم النماذج:
```
cd services/emotion-engine
docker build -t ahla/emotion-engine:2.0.0 -f docker/Dockerfile .
docker run -p 8088:8088 ahla/emotion-engine:2.0.0
```
2) تكامل Next.js: ضع `NEXT_PUBLIC_EMOTION_ENGINE_URL=http://localhost:8088` ثم فعّل Prisma من `integrations/prisma/additions.prisma`.
3) MLflow:
```
cd infra/mlflow && docker compose up -d
```
4) Autotrain:
- غيّر جدول GitHub Actions في `infra/github-actions/emotion-ci.yml` حسب منطقتك الزمنية (تشغيل أسبوعي).
- أو شغّل Prefect يدويًا:
```
python training/prefect/flow.py
```

## ملاحظات الخصوصية
- لتفعيل تحليل **على الجهاز**، استخدم `edge/ondevice-web/index.html` أو تطبيقات موبايل لاحقًا.
- لتفعيل التعلم الاتحادي، شغّل خادم Flower وعملاء الأجهزة.

