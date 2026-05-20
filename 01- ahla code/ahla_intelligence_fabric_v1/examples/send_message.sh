#!/usr/bin/env bash
curl -s -X POST http://localhost:8000/event -H 'content-type: application/json' -d '{
  "topic":"chat.events",
  "key":"u1",
  "value":{"id":"m1","user_id":"u1","text":"اهلاً! هذا اختبار للمشاعر!!"}
}'
echo
