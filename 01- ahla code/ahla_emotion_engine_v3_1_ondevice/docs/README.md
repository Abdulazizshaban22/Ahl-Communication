# Ahla Emotion Engine v3.1 — On-Device + FeatureViews + Label Studio Webhook
Build date: 2025-10-19

## ما الجديد؟
- **On-Device افتراضي** لسياقات (personal/family): لا نخزن نص الرسالة، نخزن **نتائج مجمّعة** فقط.
- **Webhook** جاهز من Label Studio → يحفظ payloads في `/tmp/labelstudio/inbox` لمعالجة التدريب.
- **FeatureViews إضافية** في Feast: `response_rate_1h_7d`, `avg_message_length_7d`, `positive_emoji_ratio_7d`.
- **جسر NATS → Label Studio**: يرسل الرسائل منخفضة الثقة كمهام ترميز.

## تشغيل سريع
```bash
# (1) حساب الميزات للأوفلاين ستور (Feast)
python feast_repo/jobs/compute_chat_metrics.py
cd feast_repo && feast apply

# (2) تفعيل الجسر (اختياري)
python nats/bridges/lowconf_to_labelstudio.py

# (3) Next.js ingest يراعي سياسات الخصوصية تلقائيًا
POST /api/emotion/ingest  # يختزل النص إذا كانت السياسة تمنع التخزين
```
