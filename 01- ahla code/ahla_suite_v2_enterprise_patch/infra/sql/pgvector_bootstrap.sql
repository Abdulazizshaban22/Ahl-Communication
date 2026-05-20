-- Enable pgvector extension and sample table
CREATE EXTENSION IF NOT EXISTS vector;
CREATE TABLE IF NOT EXISTS messages (
  id TEXT PRIMARY KEY,
  chat_id TEXT,
  body TEXT,
  embedding VECTOR(1536)
);
-- Example index (HNSW) for ANN search
CREATE INDEX IF NOT EXISTS idx_messages_embedding ON messages USING hnsw (embedding vector_cosine_ops);
