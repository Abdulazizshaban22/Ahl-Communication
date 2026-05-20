# Ahla Suite v1.8 — Geo-IP Maps + Lambda GeoIP Layer + SLO Alerts

## Geo-IP Maps (Grafana → OpenSearch)
- Import `grafana/dashboards/ahla_geomap_geoip.json`.
- Uses `ip2geo.location` (geo_point) for heatmap layers.

## Lambda GeoIP Layer (MaxMind)
- Build a Lambda Layer with `maxminddb` + `GeoLite2-City.mmdb`.
- Attach the layer to the ALB logs Lambda and use `terraform/envs/prod/lambda_alb_s3_to_firehose_geoip.zip`.

## SLO Alerts
- Import monitors:
  - `opensearch/monitors/apdex_breach_monitor.json`
  - `opensearch/monitors/latency_budget_hourly.json`
  - `opensearch/monitors/latency_budget_daily.json`
- Replace `<REPLACE-SNS-DESTINATION-ID>` with your Notifications SNS channel id.

