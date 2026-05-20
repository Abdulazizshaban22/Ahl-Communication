#!/usr/bin/env bash
# Usage:
#   OS_ENDPOINT="https://<your-os-endpoint>" OS_USER="admin" OS_PASS="..." bash scripts/apply_ip2geo.sh
set -euo pipefail
: "${OS_ENDPOINT:?Missing OS_ENDPOINT}"
: "${OS_USER:?Missing OS_USER}"
: "${OS_PASS:?Missing OS_PASS}"

echo "Creating ip2geo datasource (GeoLite2 City) if missing..."
curl -sS -u "$OS_USER:$OS_PASS" -X PUT "$OS_ENDPOINT/_plugins/geospatial/ip2geo/datasource/ahla-geoip-ds"   -H 'Content-Type: application/json'   -d '{"endpoint":"https://geoip.maps.opensearch.org/v1/geolite2-city/manifest.json","update_interval_in_days":3}' || true

echo "Creating ingest pipeline..."
curl -sS -u "$OS_USER:$OS_PASS" -X PUT "$OS_ENDPOINT/_ingest/pipeline/ahla-ip2geo"   -H 'Content-Type: application/json' --data-binary @opensearch/pipelines/ahla-ip2geo.json

echo "Upserting index template (default_pipeline=ahla-ip2geo)..."
curl -sS -u "$OS_USER:$OS_PASS" -X PUT "$OS_ENDPOINT/_index_template/ahla-template"   -H 'Content-Type: application/json' --data-binary @opensearch/templates/ahla-template.json

echo "Done. New writes to indices matching ahla-* will be geo-enriched."
