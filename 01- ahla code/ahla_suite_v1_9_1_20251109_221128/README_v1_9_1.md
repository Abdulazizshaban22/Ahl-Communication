# Ahla Suite v1.9.1 — Custom Choropleth, Route SLOs, OSI via Kinesis

## Included
- **Custom Regions Choropleth**: `grafana/dashboards/ahla_choropleth_custom_regions.json` + `geo/regions_example.geojson`
  - Variables: SERVICE, ROUTE, COUNTRY, T (Apdex).
- **SLO/Apdex by Routes**: `grafana/dashboards/ahla_slo_routes.json` + OpenSearch monitors:
  - `opensearch/monitors/apdex_api_send.json`
  - `opensearch/monitors/apdex_webrtc_offer.json`
- **OpenSearch Ingestion (Kinesis)**: `opensearch-ingestion/pipeline-osi-kinesis.yaml`

## Notes
- To use custom regions, replace `geo/regions_example.geojson` with your authoritative boundaries, and keep property key `region_iso_code` for joining with `ip2geo.region_iso_code`.
- Grafana needs `GF_PANELS_ENABLE_ALPHA=true` to show dynamic GeoJSON (if you later switch to fetching via URL). Static embedded GeoJSON works without alpha.
- The SLO/Apdex panels/monitors assume fields `request_url`, `target_processing_time`, `elb_status_code`, `user_agent`, `client_ip` exist in your documents.

Generated at: 2025-11-09T22:11:28.764089
