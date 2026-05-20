
# Ahla Chat v3.2 — Sovereign Emotion Full Suite

- Web Push (VAPID) + PWA.
- Moments (encoder presets) — واجهة مبسطة.
- Emotion & Tone APIs (نصي + صوتي).
- Prometheus + Grafana Dashboard.
- Skeletons لبنية ECS Blue/Green.

## محليًا
cd infra
docker compose up -d --build

- واجهة: http://localhost:8095/chat
- Grafana: http://localhost:3001 (admin/admin)
- Prometheus: http://localhost:9090

## Push
توليد مفاتيح VAPID:
docker run --rm -v $PWD/../services/push-tools:/w -w /w node:20 node generate_vapid.js
ثم مرّر القيم عبر متغيرات البيئة قبل التشغيل.

