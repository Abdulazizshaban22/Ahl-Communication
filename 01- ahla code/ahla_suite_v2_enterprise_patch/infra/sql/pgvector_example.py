# Example: store & query embeddings with pgvector (psycopg)
import os, psycopg
from math import sqrt
conn = psycopg.connect(os.getenv("DATABASE_URL","postgres://postgres:postgres@localhost:5432/postgres"))
cur = conn.cursor()
cur.execute("CREATE EXTENSION IF NOT EXISTS vector")
cur.execute("CREATE TABLE IF NOT EXISTS messages (id text primary key, chat_id text, body text, embedding vector(4))")
cur.execute("INSERT INTO messages VALUES ('1','demo','hello',[0.1,0.2,0.3,0.4]) ON CONFLICT DO NOTHING")
cur.execute("SELECT id, body FROM messages ORDER BY embedding <-> '[0.1,0.2,0.3,0.4]' LIMIT 5")
print(cur.fetchall())
conn.commit(); conn.close()
