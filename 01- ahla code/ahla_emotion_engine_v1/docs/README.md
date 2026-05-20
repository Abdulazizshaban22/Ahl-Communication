# Ahla Emotion Engine v1
**Build date:** 2025-10-19

محرك عاطفي سياقي يفهم نبرة الرسائل وسياق العلاقة ويقترح تفاعلات لطيفة.

## المزايا
- تصنيف **المشاعر** (GoEmotions via zero-shot على XLM-R)  
- **المعنويات** (إيجابي/محايد/سلبي) باستخدام نموذج متعدد اللغات
- **السُميّة** (toxic/insult/…)
- **قواعد سلوكية** جاهزة (تهدئة الخلاف، شكر في بيئة العمل، إجهاد ليلي)
- تكامل **Next.js** + **Prisma** + **مكوّن واجهة** لاقتراحات لطيفة

## التشغيل محليًا
```bash
cd services/emotion-engine
docker build -t emotion-engine:cpu -f docker/Dockerfile .
docker run -p 8088:8088 emotion-engine:cpu
```
ثم من مشروع الويب:
- ضع `NEXT_PUBLIC_EMOTION_ENGINE_URL=http://localhost:8088` في `.env`
- أضف جداول Prisma من `integrations/prisma/additions.prisma` ثم:
```bash
npx prisma generate && npx prisma migrate dev --name emotion_engine
```
- استدعِ API الإدخال: `POST /app/api/emotion/ingest` مع `{chat_id, message_id, author_id, text, context}`.

## الموديلات (قابلة للاستبدال)
- Sentiment: cardiffnlp/twitter-xlm-roberta-base-sentiment (متعدد اللغات)
- Toxicity: unitary/multilingual-toxic-xlm-roberta (متعدد اللغات)
- Emotion (zero-shot): joeddav/xlm-roberta-large-xnli + تصنيفات GoEmotions
يمكنك تعديلها في `config/engine.yaml`.

## الخصوصية
- يمكن تشغيل المحرك محليًا أو على خادم خاص.
- احفظ فقط **النتائج** وليس النص الأصلي إن رغبت (عدّل route لتجاهل النص).
- غيّر الحدود والقواعد حسب السياق.
