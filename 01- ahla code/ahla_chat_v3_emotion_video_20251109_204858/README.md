# Ahla Chat v3 — Emotion + Video

حزمة توسعة كاملة لـ Ahla Chat تضيف:
- **Ahla Moments**: تسجيل فيديو قصير (≤60s) ورفعه + توليد صور مصغّرة (FFmpeg).
- **Safety Number** للتحقق (ملخص مفتاح الجهاز العام).
- **اختفاء الرسائل** (TTL لكل غرفة).
- **Emotion API** أولي لقياس حدّة النقاش (قابل لاستبداله بنموذج ML).

## التشغيل
```bash
cd infra
docker compose up -d --build
# الويب (v3): http://localhost:8091/chat
# Moments API:  http://localhost:8010/health
# Emotion API:  http://localhost:8020/health
```

## للترقية التالية
- اعتماد **WebCodecs** لتحسين الترميز (إن توفر) + هاردوير.
- دمج **tfjs toxicity** داخل المتصفح لتحليل محلي.
- ترقية E2EE إلى **Double Ratchet/X3DH** أو **MLS** للمجموعات.