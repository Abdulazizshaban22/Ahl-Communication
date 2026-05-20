#!/usr/bin/env bash
set -e
curl -sf http://localhost:8000/health && echo ' chat-api OK'
curl -sf http://localhost:8010/health && echo ' emotion OK'
curl -sf http://localhost:8020/health && echo ' meet-api OK'
