# Ahla v3.1 — Intelligence + Observability + MSK (Patch)

## 1) الذكاء داخل Chat/Meet
- **Chat (E2EE)**: فعّل Signal/MLS عبر الملفات في `ahla-chat/e2ee/` (استبدل placeholders بمكتبات جاهزة).
- **Meet E2EE**: اربط `insertable-streams.js` و`worker.js` ضمن واجهة meet-web، ثم استبدل التشفير بـ **SFrame** لاحقًا.

## 2) المراقبة اللحظية
- **OpenSearch Ingestion**: حدّد `AWS_REGION` و`OPENSEARCH_ENDPOINT` في `observability/opensearch/pipeline.yaml` وانشر الـpipeline.
- **Grafana**: استورد لوحة `observability/grafana/dashboards/latency_apdex.json` واضبط الـdatasource إلى CloudWatch/OpenSearch.

## 3) ترحيل NATS → MSK Serverless (IAM)
- أنشئ MSK Serverless وأضف سياسة IAM للقراءة/الكتابة.
- استبدل مستهلك/منتِج NATS بعملاء Kafka مستخدمين `msk/py/consumer_iam.py` كنموذج.

> ملاحظات أمنية:
> - منع تخزين المفاتيح الخاصة على الخوادم.
> - تأكد من الالتزام بـPDPL (إشعار خروقات خلال 72 ساعة، سجلات موافقات/DSR).
