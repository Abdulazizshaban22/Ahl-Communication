#!/usr/bin/env bash
# Create a one-off silence via Grafana Alerting API (Grafana-managed Alertmanager)
# Requirements: GRAFANA_URL, GRAFANA_TOKEN
set -euo pipefail

: "${GRAFANA_URL:?GRAFANA_URL is required (e.g., https://grafana.example.com)}"
: "${GRAFANA_TOKEN:?GRAFANA_TOKEN is required (Grafana API token)}"

START=${START:-"$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
END=${END:-"$(date -u -d '+1 hour' +%Y-%m-%dT%H:%M:%SZ)"}
COMMENT=${COMMENT:-"Ahla scheduled maintenance"}

payload=$(cat <<JSON
{
  "matchers": [
    {"name":"service", "value": "chat|meet|drive|mail", "isRegex": true}
  ],
  "startsAt": "$START",
  "endsAt": "$END",
  "createdBy": "ahla-ops",
  "comment": "$COMMENT"
}
JSON
)

curl -sS -X POST "$GRAFANA_URL/api/alertmanager/grafana/api/v2/silences" \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$payload"
echo
echo "Silence created from $START to $END"
