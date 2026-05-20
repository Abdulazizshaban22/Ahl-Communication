# Ahla Productivity v5 — Runtime Ready
Build: 2025-10-20T05:49:48.442075Z

This bundle upgrades the skeleton to **fully runnable apps** (local/dev) with real collaboration and persistence:
- Next.js apps: Notes, Book, Graph, Dote, Dash.
- Services: `collab-gateway` (y-websocket) and `content-api` (FastAPI + SQLite) — ready out of the box.
- Docker Compose to boot the services instantly.

Quick start:
```bash
docker compose -f docker-compose.dev.yml up -d    # start collab + content-api (+ optional Superset)
# In another shell:
cd apps/notes-web  && npm i && npm run dev  # http://localhost:3010
cd apps/book-web   && npm i && npm run dev  # http://localhost:3020
cd apps/graph-web  && npm i && npm run dev  # http://localhost:3030
cd apps/dote-web   && npm i && npm run dev  # http://localhost:3040
cd apps/dash-web   && npm i && npm run dev  # http://localhost:3050
```
Configuration is via `.env` files in each app. See `.env.example` in every app directory.

Notes:
- Collaboration uses **Yjs** + **Tiptap Collaboration** bound via **y-websocket**. Saving/persistence uses `content-api` REST.
- `content-api` defaults to **SQLite** (`/data/content.db`) for zero‑dependency startup. Switch to Postgres by setting `DATABASE_URL`.
