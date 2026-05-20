
from fastapi import FastAPI
from pydantic import BaseModel
from opensearchpy import OpenSearch, RequestsHttpConnection
import os

OS_URL = os.getenv("OPENSEARCH_URL","http://localhost:9200")
OS_USER = os.getenv("OPENSEARCH_USERNAME","")
OS_PASS = os.getenv("OPENSEARCH_PASSWORD","")

def client():
    auth = (OS_USER, OS_PASS) if OS_USER else None
    return OpenSearch(OS_URL, http_auth=auth, use_ssl=OS_URL.startswith("https"), verify_certs=False,
                      connection_class=RequestsHttpConnection)

app = FastAPI(title="Ahla Analyze", version="1.0")

class LogIn(BaseModel):
    service: str
    event: dict

@app.post("/log")
def log_event(inp: LogIn):
    idx = f"ahla-{inp.service}-events"
    resp = client().index(index=idx, body=inp.event)
    return {"indexed": True, "id": resp.get("_id")}

@app.get("/health")
def health():
    return {"ok": True}
