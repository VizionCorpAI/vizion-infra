# MT5 Low‑Latency Copy Trade (Demo → Live)

This setup uses ZeroMQ for low‑latency copy trading.

## Topology
- Demo MT5 publishes events (PUB) → `mt5-bridge-demo` (SUB)
- Copytrade service forwards → `mt5-bridge-live` (DEALER)
- Live MT5 executes

## Containers
- `vizion-mt5-demo` (port 3000)
- `vizion-mt5-live` (port 3001)
- `vizion-mt5-bridge-demo`
- `vizion-mt5-bridge-live`
- `vizion-mt5-copytrade`

## Config Files
- Demo bridge: `vizion-trading/infra/runtime/mt5-bridge/config/demo.env`
- Live bridge: `vizion-trading/infra/runtime/mt5-bridge/config/live.env`
- Copytrade: `vizion-trading/infra/runtime/mt5-bridge/config/copytrade.env`

## EA Requirements
Your MT5 EA must support ZMQ:
- **Commands**: connect DEALER to `mt5-bridge-*:5011/5101` (per account)
- **Events**: bind PUB to `:5012/5022/5102/5202` inside MT5

## Start/Stop
```bash
cd /root/VizionAI/WORKSPACES/vizion-trading/infra/runtime/mt5-container

docker compose up -d
# docker compose down
```

## Notes
- Demo → Live copy direction is set in `copytrade.env`.
- For other directions, swap endpoints.
