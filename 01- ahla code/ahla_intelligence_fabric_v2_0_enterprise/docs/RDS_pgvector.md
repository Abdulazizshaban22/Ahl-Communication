# RDS Postgres 16 — pgvector
After cluster creation:
```sql
CREATE EXTENSION IF NOT EXISTS vector;
```
If installation fails, verify engine minor version supports pgvector and parameter group allows trusted extensions.
