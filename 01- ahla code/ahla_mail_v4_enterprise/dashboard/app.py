from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, JSONResponse
from jinja2 import Environment, FileSystemLoader, select_autoescape
import pandas as pd, os

app = FastAPI(title="Ahla Deliverability Dashboard")

TEMPLATES = Environment(loader=FileSystemLoader("templates"), autoescape=select_autoescape())

def load_csv(path):
    if os.path.exists(path):
        return pd.read_csv(path)
    return pd.DataFrame()

@app.get("/", response_class=HTMLResponse)
def index():
    tls = load_csv("/data/tlsrpt.csv")
    dmarc = load_csv("/data/dmarc_rua.csv")
    tls_ok = int(tls["total_success"].sum()) if "total_success" in tls else 0
    orgs = list(dmarc["org"].unique()) if "org" in dmarc else []
    tpl = TEMPLATES.get_template("index.html")
    return tpl.render(tls_ok=tls_ok, orgs=orgs)

@app.get("/api/tls")
def api_tls():
    tls = load_csv("/data/tlsrpt.csv")
    return JSONResponse(tls.to_dict(orient="records"))

@app.get("/api/dmarc")
def api_dmarc():
    dmarc = load_csv("/data/dmarc_rua.csv")
    return JSONResponse(dmarc.to_dict(orient="records"))
