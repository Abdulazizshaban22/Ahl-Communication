import os, numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import psycopg
from prometheus_client import Counter, Histogram, start_http_server

DB_URL = os.getenv("DATABASE_URL")
if not DB_URL:
    raise RuntimeError("Set DATABASE_URL")

app = FastAPI(title="Ahla Semantic Search", version="ultra-v1")
REQS = Counter("search_requests_total","Search requests")
LAT = Histogram("search_request_seconds","Search latency", buckets=[.01,.05,.1,.25,.5,1,2])
start_http_server(9003)

def init_db():
    with psycopg.connect(DB_URL) as con:
        con.execute("CREATE EXTENSION IF NOT EXISTS vector")
        con.execute("CREATE TABLE IF NOT EXISTS items(id text primary key, embedding vector(768), meta jsonb)")
        con.execute("CREATE INDEX IF NOT EXISTS items_embedding_idx ON items USING ivfflat (embedding vector_cosine_ops) WITH (lists=100)")
init_db()

class UpsertReq(BaseModel):
    id: str
    embedding: list[float]
    meta: dict | None = None

class QueryReq(BaseModel):
    embedding: list[float]
    top_k: int = 10

@app.get("/healthz")
def healthz(): return {"ok": True}

@app.post("/v1/upsert")
def upsert(r: UpsertReq):
    REQS.inc()
    if len(r.embedding) != 768:
        raise HTTPException(400, "embedding must be 768 dims (example)")
    with LAT.time(), psycopg.connect(DB_URL) as con:
        con.execute("INSERT INTO items(id,embedding,meta) VALUES (%s,%s,%s) ON CONFLICT (id) DO UPDATE SET embedding=EXCLUDED.embedding, meta=EXCLUDED.meta",
                    (r.id, np.array(r.embedding), json.dumps(r.meta or {})))
    return {"ok": True}

@app.post("/v1/query")
def query(r: QueryReq):
    REQS.inc()
    with LAT.time(), psycopg.connect(DB_URL) as con:
        cur = con.execute("SELECT id, 1 - (embedding <=> %s) AS cos_sim, meta FROM items ORDER BY cos_sim DESC LIMIT %s",
                          (np.array(r.embedding), r.top_k))
        rows = [{"id": i, "score": float(s), "meta": m} for (i,s,m) in cur.fetchall()]
    return {"results": rows}
