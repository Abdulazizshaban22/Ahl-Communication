#!/usr/bin/env bash
set -euo pipefail
PY=${1:-python3.12}
WD=$(cd "$(dirname "$0")" && pwd)
OUT="$WD/geoip_layer.zip"
TMP=$(mktemp -d)
mkdir -p "$TMP/python/lib/$PY/site-packages"
pip install maxminddb -t "$TMP/python/lib/$PY/site-packages" >/dev/null
[ -f "$WD/GeoLite2-City.mmdb" ] && cp "$WD/GeoLite2-City.mmdb" "$TMP/GeoLite2-City.mmdb" || echo "Missing GeoLite2-City.mmdb"
(cd "$TMP" && zip -qr "$OUT" .)
echo "Layer built at $OUT"
