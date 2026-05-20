#!/usr/bin/env bash
set -euo pipefail

OLD=${1:-"../Ahla_Hero_v60_FullSuite"}
NEW_ROOT="$(cd "$(dirname "$0")/.."; pwd)"

echo "Migrating from $OLD to $NEW_ROOT"
# copy UI pages if exist
if [ -d "$OLD/apps/web/app" ]; then
  rsync -a --exclude 'api' "$OLD/apps/web/app/" "$NEW_ROOT/apps/web/app/"
fi

# copy public assets
if [ -d "$OLD/apps/web/public" ]; then
  rsync -a "$OLD/apps/web/public/" "$NEW_ROOT/apps/web/public/"
fi

# keep old README/SECURITY docs
if [ -f "$OLD/SECURITY_HARDENING.md" ]; then
  cp "$OLD/SECURITY_HARDENING.md" "$NEW_ROOT/docs/SECURITY_HARDENING.legacy.md"
fi
if [ -f "$OLD/Runbook.md" ]; then
  cp "$OLD/Runbook.md" "$NEW_ROOT/docs/Runbook.legacy.md"
fi

echo "Done. Now run:"
echo "  docker compose -f deploy/docker-compose.core.yml up -d"
echo "  cd apps/web && npm i && npx prisma generate && npx prisma migrate dev --name init"
