# Ahla Suite v1.9 — Choropleth + Markers, Apdex-per-service, OpenSearch Ingestion

## What’s included
- `grafana/dashboards/ahla_geomap_choropleth_markers.json` — choropleth by country (24h) + interactive markers with UA/URI.
- `opensearch/monitors/apdex_*.json` — OpenSearch Alerting monitors for Apdex per service (chat/meet/drive/mail/business).
- `opensearch-ingestion/pipeline-osi-alb-s3.yaml` — Amazon OpenSearch Ingestion (Data Prepper) pipeline to ingest ALB access logs from S3 via SQS notifications, parse, GeoIP-enrich, and send to OpenSearch index.

## Enable Dynamic GeoJSON (alpha) in Grafana
Add environment variable: `GF_PANELS_ENABLE_ALPHA=true` before running Grafana. Then import the dashboard JSON.

## Notes
- Choropleth layer joins a country ISO-2 property (ISO_A2) to the aggregated count by `ip2geo.country_iso_code.keyword`.
- Markers layer expects a doc field `ip2geo.location` (OpenSearch `geo_point`) or the renamed `ip2geo_location` if you ingest via OSI.
- Apdex thresholds (T): chat=0.5s, meet=1.0s, drive=1.2s, mail=0.8s, business=1.0s. Adjust in the JSON if needed.
- OSI pipeline expects ALB logs gzip in S3 with SQS notifications. Fill placeholders (region, bucket, sqs url, domain endpoint).

Generated: 2025-11-09T22:06:17.892259
