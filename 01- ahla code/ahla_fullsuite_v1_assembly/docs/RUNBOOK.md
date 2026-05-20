# Runbook (تشغيل + صحة)

- صحة Postgres: `docker logs <db>` و `pg_isready`
- صحة MinIO: http://localhost:9001 (Console)
- صحة ONLYOFFICE: http://localhost:8082 (تحقق من JWT)
- صحة Chat WS: `wscat -c ws://localhost/ws/chat`
- صحة SFU: ws://localhost:7000/ws (عبر الديمو أو متصفح)، وتأكد من ICE/TURN
- Prisma: dev = `migrate dev`، إنتاج = `migrate deploy` ضمن CI

