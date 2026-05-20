-- Ahla Chat minimal storage
create table if not exists chat_rooms(
  id uuid primary key,
  org_id text not null,
  title text,
  kind text default 'direct',
  created_at timestamptz default now()
);
create table if not exists chat_messages(
  id bigserial primary key,
  room_id uuid references chat_rooms(id),
  user_id text,
  author text,
  ts timestamptz,
  payload jsonb,
  created_at timestamptz default now()
);
create index if not exists chat_messages_room_ts on chat_messages(room_id, ts);
create index if not exists chat_messages_payload_gin on chat_messages using gin(payload jsonb_path_ops);
