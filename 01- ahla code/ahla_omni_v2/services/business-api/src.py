from fastapi import FastAPI
app = FastAPI(title="Ahla Business API v2")
@app.get("/healthz")
def healthz(): return {"ok": True}
@app.get("/ping")
def ping(): return {"pong": True}
