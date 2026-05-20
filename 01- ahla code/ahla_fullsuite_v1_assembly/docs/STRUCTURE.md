# ترتيب الملفات (Structure)

/apps/web
  ├─ app
  │   ├─ page.tsx
  │   └─ api
  │       ├─ auth/[...nextauth]/route.ts
  │       ├─ drive/signed-url/route.ts
  │       ├─ mail/send/route.ts
  │       └─ meetings/create/route.ts
  ├─ lib (auth.ts, prisma.ts, s3.ts, mail.ts)
  ├─ prisma/schema.prisma
  ├─ scripts/seed-admin.js
  ├─ package.json, tsconfig.json, next.config.js, Dockerfile

/services
  ├─ chat-ws (index.js, package.json)
  ├─ sfu (config.toml)
  └─ coturn (turnserver.conf)

/deploy
  ├─ docker-compose.core.yml      # DB/Redis/MinIO/OnlyOffice/Chat-WS/Web/Nginx
  ├─ docker-compose.sfu.yml       # SFU + CoTURN
  └─ nginx.conf                   # WS proxy

/ENV_TEMPLATES (.env.core.example, .env.sfu.example)
/docs (README, MIGRATION_PLAN, RUNBOOK, STRUCTURE)
/scripts (migrate-from-hero-v60.sh)
