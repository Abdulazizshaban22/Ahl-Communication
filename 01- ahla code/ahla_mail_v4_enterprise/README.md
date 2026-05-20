# Ahla Mail v4 Enterprise
Build: 2025-10-20T04:26:14.986093Z

يشمل:
- ضبط Stalwart Enterprise: ACME، JMAP Push/EventSource، ManageSieve، AI Models.
- سكربت Sieve Enterprise مدمج مع llm_prompt لتصنيف ذكي.
- ترقيات Webmail: ملف اتصال SSE (EventSource) + مسارات بحث ورفع مرفقات عبر JMAP.
- لوحة Deliverability (FastAPI + Chart.js) لعرض TLS-RPT/DMARC CSV من v3.

تشغيل لوحة المراقبة:
```
cd infra
docker compose up -d --build
# تفتح http://localhost:8088
```
دمج Sieve Enterprise:
- ارفع `sieve/enterprise_auto_classify.sieve` عبر ManageSieve (المنفذ 4190) أو واجهة الإدارة.
- يتطلب ميزة Enterprise لـ Stalwart لتفعيل `llm_prompt` و `enterprise.ai.<id>`.
