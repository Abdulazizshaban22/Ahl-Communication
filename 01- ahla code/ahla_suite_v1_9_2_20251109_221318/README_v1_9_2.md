# Ahla Suite v1.9.2 — KSA Official Geo (scaffold) + Weekly SLO & Slack/Email Alerts

## 1) KSA Geo — Choropleth
- عدّل متغير `KSA_GEOJSON_URL` في Grafana (أو غيّره في لوحة `ahla_geo_ksa.json`) ليشير إلى GeoJSON الرسمي لمناطق المملكة.
- إن كان ملفك لا يحوي الحقل `region_iso_code`، استخدم:
  ```bash
  python3 scripts/normalize_ksa_geojson.py <source.geojson> geo/ksa_regions_normalized.geojson
  ```
  ثم ارفع الناتج إلى S3 أو قدّمه عبر Nginx، ومرّر URL إلى اللوحة.
- فلاتر متاحة: COUNTRY/REGION/CITY/SERVICE/ROUTE.

## 2) Weekly SLO / Apdex by Route
- استورد `grafana/dashboards/ahla_slo_weekly.json`.
- OpenSearch Monitors:
  - `opensearch/monitors/weekly_apdex_upload.json` (T=0.8s)
  - `opensearch/monitors/weekly_apdex_auth_callback.json` (T=0.7s)
- أنشئ قنوات Notifications: SNS و Slack webhook وانسخ الـ`destination_id` مكان القيم المؤقتة.

## 3) ملاحظات
- الحقول المعتمدة: `ip2geo.country_iso_code`, `ip2geo.region_iso_code`, `ip2geo.city_name`, `ip2geo.location`, `request_url`, `target_processing_time`, `elb_status_code`, `user_agent`.
- لو أردت توحيد `region_iso_code` مع رموز ISO-3166-2 الرسمية، عدّل السكربت بما يلائم خصائص ملفك الرسمي.
- جميع اللوحات تعمل مع **OpenSearch datasource** في Grafana وبيانات `ahla-*`.

تم الإنشاء: 2025-11-09T22:13:18.775229
