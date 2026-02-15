# Runtime Topology

## Containers
- OpenClaw: `0.0.0.0:48950`
- n8n: `0.0.0.0:32769`
- Postgres: `0.0.0.0:32770`
- Vaultwarden: `0.0.0.0:32768`

## Services
- NN server: `vizion-nn.service` on `:8000`
- Scheduler: `vizion-scheduling-runner.timer`

## Health Endpoints
- NN: `http://127.0.0.1:8000/health`
- OpenClaw: `http://127.0.0.1:48950/`
- n8n: `http://127.0.0.1:32769/`
- Vaultwarden: `http://127.0.0.1:32768/`
