#!/usr/bin/env bash
set -e
echo "Checking health endpoints..."
curl -sf http://localhost:8000/health && echo " chat-api OK"
curl -sf http://localhost:8010/health && echo " emotion-engine OK"
echo "Done."
