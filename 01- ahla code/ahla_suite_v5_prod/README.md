# Ahla Suite v5 — Production Starter
Build: 2025-10-20T08:47:51.140771Z

يشمل:
- **apps/** سبعة تطبيقات (Vite + React) تعمل فورًا (Drive/Meet/Notes/Book/Graph/Dote/Dash).
- **infra/** قيم Helm لخدمات الأساس: NATS (JetStream + WebSocket)، CoTURN (443/TLS)، MinIO، Postgres، Grafana Stack.
- **.github/workflows/** CI للبناء والفحص وإصدار الصفحات.

## تشغيل أي تطبيق محليًا
```bash
cd apps/<app>
npm install
npm run dev
```

## نشر سريع على Kubernetes (Helm)
- NATS مع WebSocket وJetStream
- CoTURN على 443/TLS
- MinIO + Postgres
- Grafana/Prometheus/Tempo/Loki (قوالب قيم أولية)

> استخدم هذه كبداية قابلة للتوسعة. الانتقال إلى الإنتاج يتطلب ضبط DNS/Certificates/Autoscaling وسياسات الأمان.
