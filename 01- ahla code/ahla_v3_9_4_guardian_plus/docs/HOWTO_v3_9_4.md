# Ahla v3.9.4 — Guardian+

## 1) ACFP/ATP — App Integration
- فعّل ACFP لمسار التسجيل `/auth/register` وATP لمسار الدخول `/auth/login`.
- استخدم تكوين الاستجابة في ATP لتمييز النجاح/الفشل (200/204/302 نجاح — 400/401/403 فشل).
- حمّل توكن AWS WAF عبر JS Integration (cookie: `aws-waf-token`).

## 2) WebRTC Metrics
- اجمع jitter/packet loss/jitterBufferDelay/TargetDelay عبر getStats كل 5 ثوانٍ.
- أرسلها إلى `/aif/ingest/webrtc` → Kafka/MSK موضوع `aif.webrtc.metrics`.

## 3) PDPL Evidence Pack
- التصدير من OpenSearch (SNS indexer سبق إعداده) كـ NDJSON.
- شغّل: `node evidence/export_incidents_to_html.js incidents.ndjson evidence.html` ثم حولها إلى PDF.

> تذكير: راقب الإشعار خلال 72 ساعة وفق لوائح PDPL.
