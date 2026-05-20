from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import os

from sqlalchemy import create_engine, Column, String, Text, DateTime
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:////data/content.db")
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

class ItemIn(BaseModel):
    id: str
    kind: str
    title: str = ""
    content: str = ""

class ItemOut(ItemIn):
    updated_at: datetime

@app.get("/healthz")
def health(): return {"ok": True}

@app.get("/items", response_model=List[ItemOut])
def list_items(kind: Optional[str] = None):
    with SessionLocal() as s:
        q = s.query(Item)
        if kind: q = q.filter(Item.kind==kind)
        rows = q.order_by(Item.updated_at.desc()).all()
        return [ItemOut(id=r.id, kind=r.kind, title=r.title, content=r.content, updated_at=r.updated_at) for r in rows]

@app.get("/items/{item_id}", response_model=ItemOut)
def get_item(item_id: str):
    with SessionLocal() as s:
        r = s.get(Item, item_id)
        if not r: raise HTTPException(404, "not found")
        return ItemOut(id=r.id, kind=r.kind, title=r.title, content=r.content, updated_at=r.updated_at)

@app.post("/items", response_model=ItemOut)
def upsert_item(item: ItemIn):
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
