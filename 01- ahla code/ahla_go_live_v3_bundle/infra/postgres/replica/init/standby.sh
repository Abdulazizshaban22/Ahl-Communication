#!/usr/bin/env bash
set -e
: "${PG_PRIMARY_HOST:=postgres-primary}"
: "${PG_PRIMARY_USER:=repl_user}"
: "${PGDATA:=/var/lib/postgresql/data}"
rm -rf "$PGDATA"/* || true
pg_basebackup -h "$PG_PRIMARY_HOST" -D "$PGDATA" -U "$PG_PRIMARY_USER" -P -R
echo "hot_standby = on" >> "$PGDATA/postgresql.conf"
