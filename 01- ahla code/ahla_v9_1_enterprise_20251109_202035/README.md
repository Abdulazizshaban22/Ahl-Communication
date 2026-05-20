# Ahla v9.1 — Enterprise+

**كل شيء مُبرمج وموسّع**: SSO (Keycloak) • MinIO/S3 • TURN (coturn) • OCR + Indexer • Loki/Promtail • JWT على WS/API • Meilisearch • Grafana/Prometheus.

## التشغيل
```bash
cp .env.example .env
cd infra
docker compose up -d --build
# البوابة: http://localhost:8088
# Keycloak: http://localhost:8088 (أضف reverse-proxy rule إذا رغبت) أو http://localhost:8080 داخل الشبكة
# Grafana:  http://localhost:3001  (admin/admin)
# MinIO:    http://localhost:9001  (ahla / ahla_password)
```

## ملاحظات
- استيراد Realm تلقائيًا حسب توثيق Keycloak (import/export). 
- Meilisearch يعمل بمفتاح masterKey — غيّره للإنتاج.
- coturn يعمل بـ static creds للتجارب — غيّرها واعمل TLS للإنتاج.
- OCR يعمل عبر pytesseract وعملية worker تُقرأ من /shared/ocr_queue.
- WS محمي اختياريًا بـ JWT عبر باراميتر token في Query.

## مصادر مرجعية:
- Keycloak (استيراد Realm + تشغيل عبر الحاويات).
- coturn (TURN/STUN) و أفضل الممارسات WebRTC.
- MinIO S3 SDK (Python).
- Meilisearch (التشغيل الذاتي).
- Prometheus/Grafana و starlette_exporter.
- PDPL (SDAIA) — سياسة الخصوصية وإجراءات DSR.
```
