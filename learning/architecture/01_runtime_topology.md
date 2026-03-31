# Runtime Topology

## Containers
- OpenClaw: `0.0.0.0:48950`
- n8n: `0.0.0.0:32769`
- n8n task runners: internal sidecar, no host port
- Postgres: `0.0.0.0:32770`

## Services
- NN server: `vizion-nn.service` on `:8000`
- Scheduler: `vizion-scheduling-runner.timer`

## Health Endpoints
- NN: `http://127.0.0.1:8000/health`
- OpenClaw: `http://127.0.0.1:48950/`
- n8n: `http://127.0.0.1:32769/`

## n8n Runtime Notes
- n8n runs in `external` task-runner mode.
- The runner sidecar talks to the n8n broker on internal port `5679`.
- The runner container should not expose a host port.
