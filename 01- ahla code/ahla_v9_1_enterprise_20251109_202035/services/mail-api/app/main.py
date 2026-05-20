from fastapi import FastAPI
from starlette_exporter import PrometheusMiddleware, handle_metrics
app = FastAPI(title="Ahla Mail API",version="0.2.0")
app.add_middleware(PrometheusMiddleware); app.add_route("/metrics", handle_metrics)

MAIL = [
    {"id":"1","from":"team@ahla.sa","subject":"Welcome to Ahla","snippet":"Thanks for joining..."},
    {"id":"2","from":"ops@ahla.sa","subject":"Your weekly summary","snippet":"Usage and meetings..."}
]

@app.get("/health")
def health(): return {"ok":True}

@app.get("/mail")
def list_mail(): return MAIL
