# MT5 Container (VNC) Access

This system uses a Dockerized MT5 with web VNC.

## Access URL
- `https://mt5.vizionai.iamvisioncorp.org`
- `https://mt5-live.vizionai.iamvisioncorp.org`

## Container Details
- Compose: `vizion-trading/infra/runtime/mt5-container/docker-compose.yml`
- Container names: `vizion-mt5-demo`, `vizion-mt5-live`
- Local ports: `3000` (demo), `3001` (live)

## Basic Ops

Start/stop:
```bash
cd /root/VizionAI/WORKSPACES/vizion-trading/infra/runtime/mt5-container

docker compose up -d
# docker compose down
```

## EA Mount
- EA repo path mounted read‑only:
  - `/root/VizionAI/WORKSPACES/vizion-trading/infra/mt5/ea`
- Inside container:
  - `/config/MQL5/Experts/vizion-ea`

## Notes
- Use the web UI to login and attach EAs.
- Caddy reverse proxy terminates TLS.
