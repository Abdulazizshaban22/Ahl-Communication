# Ahla Semantic Search Service (Ultra v1)
Build: 2025-10-20T09:27:29.033728Z

- Stores/queries embeddings in PostgreSQL (pgvector).
- Endpoints to upsert/query vectors.
- You can add Sentence-Transformers client in a worker to compute embeddings.

Run:
```bash
pip install -r requirements.txt
export DATABASE_URL=postgresql://user:pass@host:5432/ahladb
uvicorn main:app --host 0.0.0.0 --port 8091
```
