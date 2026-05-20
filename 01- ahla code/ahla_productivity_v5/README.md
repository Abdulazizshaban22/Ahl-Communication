# Ahla Productivity v5
Build: 2025-10-20T05:43:59.498573Z

This monorepo ships **five web apps** and **two services** wired for Ahla platform:

Apps (Next.js 14 App Router):
- **notes-web**  → Ahla Notes (Tiptap + Yjs collab)
- **book-web**   → Ahla Book (rich docs, comments, export PDF)
- **graph-web**  → Ahla Graph (slides editor MVP)
- **dote-web**   → Ahla Dote (Excel-like via Luckysheet)
- **dash-web**   → Ahla Dash (BI via Apache Superset embed/API)

Services:
- **collab-gateway** (Node.js + y-websocket) — CRDT sync for editors
- **notes-api** (FastAPI + SQLAlchemy) — metadata & storage bridge

Common:
- **packages/ui** (shared React components), **packages/types**, **packages/sdk**

Infra glue:
- Dockerfiles for each service/app
- docker-compose.dev.yml for local dev
- .env examples (RDS URL via `DATABASE_URL`), NATS base url via `NATS_URL`
