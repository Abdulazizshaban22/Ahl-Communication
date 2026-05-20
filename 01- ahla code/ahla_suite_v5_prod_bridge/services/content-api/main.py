from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import os, requests, json
from jose import jwk, jwt
from jose.utils import base64url_decode

from sqlalchemy import create_engine, Column, String, Text, DateTime
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://app_user:app_pass@postgres:5432/ahla")
engine = create_engine(DATABASE_URL, future=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

class Item(Base):
    __tablename__ = "items"
    id = Column(String, primary_key=True)
    kind = Column(String, index=True)  # note|doc|slide|sheet
    title = Column(String, default="")
    content = Column(Text, default="")
    updated_at = Column(DateTime, default=datetime.utcnow, index=True)

Base.metadata.create_all(bind=engine)
app = FastAPI(title="Ahla Content API")

# --- OIDC config (optional verification) ---
OIDC_ISSUER = os.getenv("AUTH_KEYCLOAK_ISSUER")
OIDC_AUDIENCE = os.getenv("AUTH_AUDIENCE","account")
JWKS = None
def fetch_jwks():
    global JWKS
    if not OIDC_ISSUER: return
    r = requests.get(f"{OIDC_ISSUER}/.well-known/openid-configuration", timeout=5)
    jwks_uri = r.json()["jwks_uri"]
    JWKS = requests.get(jwks_uri, timeout=5).json()

def verify_bearer(token: str) -> bool:
    if not OIDC_ISSUER: return True
    global JWKS
    if JWKS is None: fetch_jwks()
    headers = jwt.get_unverified_header(token)
    kid = headers.get("kid")
    key = None
    for k in JWKS["keys"]:
        if k["kid"] == kid: key = k; break
    if not key: return False
    try:
        data = jwt.decode(token, key, audience=OIDC_AUDIENCE, issuer=OIDC_ISSUER, options={"verify_at_hash": False})
        return True
    except Exception:
        return False

class ItemIn(BaseModel):
    id: str
    kind: str
    title: str = ""
    content: str = ""

class ItemOut(ItemIn):
    updated_at: datetime

@app.get("/healthz")
def health(): return {"ok": True, "db": str(engine.url)}

@app.get("/items", response_model=List[ItemOut])
def list_items(kind: Optional[str] = None, request: Request = None):
    # Optional: check bearer (if Authorization header present)
    auth = request.headers.get("authorization","")
    if auth.startswith("Bearer ") and not verify_bearer(auth.split(" ",1)[1]):
        raise HTTPException(401, "invalid token")
    with SessionLocal() as s:
        q = s.query(Item)
        if kind: q = q.filter(Item.kind==kind)
        rows = q.order_by(Item.updated_at.desc()).all()
        return [ItemOut(id=r.id, kind=r.kind, title=r.title, content=r.content, updated_at=r.updated_at) for r in rows]

@app.post("/items", response_model=ItemOut)
def upsert_item(item: ItemIn, request: Request = None):
    auth = request.headers.get("authorization","")
    if auth.startswith("Bearer ") and not verify_bearer(auth.split(" ",1)[1]):
        raise HTTPException(401, "invalid token")
    with SessionLocal() as s:
        r = s.get(Item, item.id)
        if not r:
            r = Item(id=item.id, kind=item.kind, title=item.title, content=item.content, updated_at=datetime.utcnow())
            s.add(r)
        else:
            r.title = item.title
            r.kind = item.kind
            r.content = item.content
            r.updated_at = datetime.utcnow()
        s.commit()
        return ItemOut(id=r.id, kind=r.kind, title=r.title, content=r.content, updated_at=r.updated_at)
