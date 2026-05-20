# Ahla Emotion Engine v3 — Full Integrations
Build date: 2025-10-19

هذه النسخة تضيف **قواعد عاطفية متقدمة + تكامل Feast (Feature Store) + قائمة انتظار NATS JetStream** + جداول تشغيل (cron) + سياسات خصوصية.

## كيف أشغّل بسرعة؟
1) شغّل Redis وNATS:
```
docker compose -f infra/docker-compose/docker-compose.yml up -d
```
2) شغّل الخدمة:
```
cd services/emotion-engine
docker build -t ahla/emotion-engine:3.0.0 -f docker/Dockerfile .
docker run -p 8088:8088 -e AE_CFG=/app/config/engine.yaml ahla/emotion-engine:3.0.0
```
3) فعّل Feast:
```
cd feast_repo
feast apply
# ارفع ميزات أولية إلى المتجر أونلاين (redis) عبر materialize/ingest حسب الحاجة
```

## فين أعدّل السلوك؟
- القواعد: `services/emotion-engine/config/engine.yaml`
- سياسة الخصوصية/الاحتفاظ: `docs/POLICY_DATA.md`
- الجداول (cron) للنشر: `infra/github-actions/emotion-pipeline.yml`

## تكامل Next.js/Prisma
- API الإدخال: `integrations/nextjs/app/api/emotion/ingest/route.ts`
- جداول Prisma: `integrations/prisma/additions.prisma`
- واجهة الاقتراحات: `integrations/ui/SmartNudge.tsx`

