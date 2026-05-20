# Enable pgvector
After Terraform, connect to the DB and run:
```sql
CREATE EXTENSION IF NOT EXISTS vector;
```
