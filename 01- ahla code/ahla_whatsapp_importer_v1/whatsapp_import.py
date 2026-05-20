#!/usr/bin/env python3
import os, sys, zipfile, io, json, uuid, shutil, re, hashlib
from datetime import datetime

SCHEMA_SQL = "-- Ahla Chat minimal storage\ncreate table if not exists chat_rooms(\n  id uuid primary key,\n  org_id text not null,\n  title text,\n  kind text default 'direct',\n  created_at timestamptz default now()\n);\ncreate table if not exists chat_messages(\n  id bigserial primary key,\n  room_id uuid references chat_rooms(id),\n  user_id text,\n  author text,\n  ts timestamptz,\n  payload jsonb,\n  created_at timestamptz default now()\n);\ncreate index if not exists chat_messages_room_ts on chat_messages(room_id, ts);\ncreate index if not exists chat_messages_payload_gin on chat_messages using gin(payload jsonb_path_ops);\n"

PATS = [
    re.compile(r'^\[(\d{1,2}/\d{1,2}/\d{2,4}), (\d{1,2}:\d{2}(?::\d{2})?) ?([AP]M)\] ([^:]+): (.*)$'),
    re.compile(r'^(\d{1,2}/\d{1,2}/\d{2,4}), (\d{1,2}:\d{2}(?::\d{2})?) ?([AP]M) - ([^:]+): (.*)$'),
    re.compile(r'^(\d{1,2}/\d{1,2}/\d{2,4}), (\d{2}:\d{2}(?::\d{2})?) - ([^:]+): (.*)$'),
]

def parse_date(groups):
    try:
        if len(groups)==5:
            d, t, ap, name, msg = groups
            fmt = "%m/%d/%y" if len(d.split("/")[-1])==2 else "%m/%d/%Y"
            if ":" in t and t.count(":")==2: t_fmt = " %I:%M:%S %p"
            else: t_fmt = " %I:%M %p"
            ts = datetime.strptime(d + t_fmt.replace("%I:%M", f" {t}"), fmt + t_fmt)
            return ts, name, msg
        elif len(groups)==4:
            d, t, name, msg = groups
            fmt = "%d/%m/%y" if len(d.split("/")[-1])==2 else "%d/%m/%Y"
            if ":" in t and t.count(":")==2: t_fmt = " %H:%M:%S"
            else: t_fmt = " %H:%M"
            ts = datetime.strptime(d + t_fmt.replace("%H:%M", f" {t}"), fmt + t_fmt)
            return ts, name, msg
    except Exception:
        return None, None, None
    return None, None, None

def iter_messages(lines):
    current=None
    for raw in lines:
        line = raw.rstrip("\n")
        matched=False
        for pat in PATS:
            m = pat.match(line)
            if m:
                matched=True
                ts, name, msg = parse_date(m.groups())
                if current: yield current
                current = {"ts": ts.isoformat()+"Z" if ts else None, "name": name, "text": msg}
                break
        if not matched:
            if current: current["text"] += "\\n" + line
    if current: yield current

def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--input", required=True, help="Path to WhatsApp export (zip or folder)")
    ap.add_argument("--out", required=True, help="Output folder")
    ap.add_argument("--self", required=True, help="Your identity (phone/email)")
    ap.add_argument("--org", default="ahla")
    ap.add_argument("--owner", default=None, help="Owner user id/email")
    args = ap.parse_args()

    os.makedirs(args.out, exist_ok=True)
    os.makedirs(os.path.join(args.out,"media"), exist_ok=True)

    schema_path = os.path.join(args.out, "schema.sql")
    import_sql_path = os.path.join(args.out, "import.sql")
    messages_jsonl = open(os.path.join(args.out, "messages.jsonl"), "w", encoding="utf-8")

    if not os.path.exists(schema_path):
        with open(schema_path, "w", encoding="utf-8") as f:
            f.write(SCHEMA_SQL)

    def new_room_id(title):
        return str(uuid.uuid5(uuid.NAMESPACE_DNS, f"{args.org}:{title}"))

    rooms = []
    inserts = []

    def process_txt(name, content):
        title = os.path.splitext(os.path.basename(name))[0]
        room_id = new_room_id(title)
        rooms.append({"id": room_id, "org_id": args.org, "title": title, "kind": "direct" if "-" not in title and "Group" not in title else "group"})
        lines = content.splitlines()
        for msg in iter_messages(lines):
            author = msg.get("name") or ""
            text = msg.get("text") or ""
            atts = []
            for token in re.findall(r'(?:attached: )?([A-Za-z0-9_\\-]+\\.(?:jpg|jpeg|png|mp4|opus|ogg|pdf|docx|xlsx))', text, flags=re.IGNORECASE):
                atts.append({"name": token, "rel": token})
            payload = {"text": text, "attachments": atts, "source":"whatsapp"}
            record = {
                "room_id": room_id,
                "user_id": args.owner or args.self,
                "author": author,
                "ts": msg.get("ts") or None,
                "payload": payload
            }
            messages_jsonl.write(json.dumps(record, ensure_ascii=False) + "\\n")
            def esc(s): return s.replace("'", "''")
            if record['ts']:
                ts_iso = record['ts'][:-1]  # drop Z
                ins = f"INSERT INTO chat_messages(room_id,user_id,author,ts,payload) VALUES ('{room_id}','{esc(record['user_id'])}','{esc(author)}',TO_TIMESTAMP('{ts_iso}','YYYY-MM-DD\" + \"T\" + \"HH24:MI:SS'),'{json.dumps(payload).replace(\"'\",\"''\")}');"
            else:
                ins = f"INSERT INTO chat_messages(room_id,user_id,author,payload) VALUES ('{room_id}','{esc(record['user_id'])}','{esc(author)}','{json.dumps(payload).replace(\"'\",\"''\")}');"
            inserts.append(ins)

        return room_id

    if zipfile.is_zipfile(args.input):
        with zipfile.ZipFile(args.input, 'r') as z:
            txt_files = [f for f in z.namelist() if f.lower().endswith(".txt")]
            # extract media
            for f in z.namelist():
                low=f.lower()
                if any(low.endswith(ext) for ext in (".jpg",".jpeg",".png",".gif",".mp4",".opus",".ogg",".pdf",".docx",".xlsx")):
                    data = z.read(f)
                    outp = os.path.join(args.out,"media", os.path.basename(f))
                    with open(outp, "wb") as fo: fo.write(data)
            for t in txt_files:
                content = z.read(t).decode("utf-8", errors="ignore")
                process_txt(t, content)
    else:
        for rootp, _, files in os.walk(args.input):
            for f in files:
                p = os.path.join(rootp,f)
                low=f.lower()
                if low.endswith(".txt"):
                    content=open(p,"r",encoding="utf-8",errors="ignore").read()
                    process_txt(f, content)
                elif any(low.endswith(ext) for ext in (".jpg",".jpeg",".png",".gif",".mp4",".opus",".ogg",".pdf",".docx",".xlsx")):
                    shutil.copy2(p, os.path.join(args.out,"media", f))

    rooms_unique = {r['id']: r for r in rooms}.values()
    with open(import_sql_path, "w", encoding="utf-8") as f:
        for r in rooms_unique:
            title = r['title'].replace("'", "''")
            f.write(f"INSERT INTO chat_rooms(id,org_id,title,kind) VALUES ('{r['id']}','{r['org_id']}','{title}','{r['kind']}') ON CONFLICT DO NOTHING;\n")
        for ins in inserts:
            f.write(ins+"\n")

    print("Done. Files written to:", args.out)

if __name__ == "__main__":
    main()
