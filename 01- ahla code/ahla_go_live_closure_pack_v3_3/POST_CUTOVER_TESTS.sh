#!/usr/bin/env bash
set -eux

APP_DOMAIN=${APP_DOMAIN:-app.ahla.example.com}

# CloudFront / TLS / headers
curl -I https://$APP_DOMAIN | sed -n '1,20p'

# ALB direct should 403 (no secret header)
ALB_DNS=${ALB_DNS:-replace-me}
curl -I https://$ALB_DNS || true

# Auth well-known
curl -s https://$APP_DOMAIN/auth/realms/ahla/.well-known/openid-configuration | jq .issuer

# WebSocket (simple)
node -e "const WebSocket=require('ws'); const ws=new WebSocket('wss://'+process.env.APP_DOMAIN+'/ws',{headers:{'X-ALB-SECRET':process.env.ALB_SECRET||''}}); ws.on('open',()=>{console.log('WS OK'); process.exit(0)}); ws.on('error',(e)=>{console.error(e); process.exit(1)})"
