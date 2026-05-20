# Ahla SFU Pack v1

Ion‑SFU (JSON‑RPC) + CoTURN + Nginx WS proxy + Browser demo.

## Run locally

```bash
docker compose -f deploy/docker-compose.sfu.yml up -d
```

Then open the demo:
`web/demo/index.html` (serve it with any static server, e.g. VS Code Live Server).
Default WS URL is `ws://localhost:7000/ws` and TURN is `localhost:3478` (creds `ahla/ahla123`).

## Notes
- If your SFU/CoTURN is behind NAT, set the **public IP** in:
  - `services/sfu/config.toml` (`nat1to1`)
  - `services/coturn/turnserver.conf` (`external-ip`)
- For production: enable TLS on both Nginx and TURN (use `cert`/`pkey` with coturn).
- Nginx snippet is in `deploy/nginx.sfu.conf`.