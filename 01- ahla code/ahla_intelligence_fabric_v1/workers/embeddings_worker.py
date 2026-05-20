import asyncio, os, json, psycopg2
from common import consumer, simple_embed, pg_conn, producer
DIM = int(os.getenv("PGVECTOR_DIM","768"))

async def main():
    cons = await consumer("chat.events")
    prod = await producer()
    conn = pg_conn(); conn.autocommit = True
    cur = conn.cursor()
    print("embeddings_worker: listening chat.events")
    try:
        async for msg in cons:
            payload = msg.value
            text = payload.get("text","")
            if not text: continue
            v = simple_embed(text, DIM)
            cur.execute("INSERT INTO embeddings (content, embedding, metadata) VALUES (%s, %s, %s)",
                        (text, list(map(float, v)), json.dumps({"user":payload.get("user_id")})))
            await prod.send_and_wait("ai.suggestions", {"type":"embedded","ref":payload.get("id")})
    finally:
        await cons.stop(); await prod.stop(); cur.close(); conn.close()

if __name__ == "__main__":
    asyncio.run(main())
