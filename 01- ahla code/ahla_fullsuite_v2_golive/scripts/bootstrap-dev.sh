#!/usr/bin/env bash
set -euo pipefail
echo "Starting core stack..."
docker compose -f deploy/docker-compose.core.yml up -d
echo "Running Prisma dev migration (dev env)"
( cd apps/web && npm i && npx prisma generate && npx prisma migrate dev --name init && node scripts/seed-admin.js )
echo "Optional: start SFU stack"
docker compose -f deploy/docker-compose.sfu.yml up -d || true
