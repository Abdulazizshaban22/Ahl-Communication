# Ahla v9.0 — SuperSuite (All Apps Programmed)

هذه الحزمة تجمع **كل تطبيقات أهلا** في تشغيل واحد:
- Chat / Meet / Drive / Business / Mail / Omni
- Emotion Engine + Omni Gateway
- Nginx + Redis + Meili + Prometheus + Grafana

## التشغيل السريع
```bash
cp .env.example .env  # إن وُجد
cd infra
docker compose up -d --build
# البوابة: http://localhost:8088
# Grafana: http://localhost:3001 (admin/admin)
```

## المسارات عبر Nginx
- /chat → chat-web
- /meet → meet-web
- /drive → drive-web
- /biz  → business-web
- /mail → mail-web
- /omni → omni-web
- /api/chat → chat-api
- /api/meet → meet-api
- /api/drive → drive-api
- /api/biz  → business-api
- /api/mail → mail-api
- /api/omni → omni-gateway
- /ws      → chat-ws
- /signal  → meet-ws

> هذه نسخة MVP تعمل فورًا، قابلة للتوسع خطوة بخطوة (E2EE، SSO، تخزين S3 فعلي، WebRTC متكامل…).
