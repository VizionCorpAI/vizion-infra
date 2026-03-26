# n8n Task Runners

This stack uses n8n task runners in `external` mode so the main n8n container stays focused on the UI, API, and execution broker, while the `n8nio/runners` sidecar executes Code node tasks.

Runtime secrets are injected from Infisical. The launcher loads platform scope secrets from the infrastructure project and Diamondreamers client scope secrets from the business project before starting the compose stack.
If Infisical DNS or auth is temporarily unavailable in the workspace, the launcher now falls back to a cached runtime env or, if available, the already-running n8n container's exported environment so the stack can still start and the live pipelines can keep moving.

## Preconditions
- n8n version 2.x or newer
- A shared `N8N_RUNNERS_AUTH_TOKEN`
- Postgres credentials for the existing n8n database
- Keep the `n8nio/runners` image on the same n8n version as the main container

## Compose Layout
- Main container: `n8n`
- Sidecar: `n8n-runners`
- Host port: `32769 -> 5678`
- Runner broker port: `5679` inside the compose network only

## Secret Sources
- Infrastructure project: `918f6641-7111-4c80-b08a-46321c6b81ab`
- Business project: `f67a6490-4cc1-489d-a6eb-98fe995b0539`
- Platform paths: `/platform/n8n`, `/n8n`, `/database/postgres`, `/social/facebook`, `/social/telegram`
- Diamondreamers paths: `/clients/diamondreamers`, `/n8n-workflows`
- Fallback cache: `/root/VizionAI/secrets/n8n-runtime.env`
- Runtime seed: the live `n8n-hxq9-n8n-1` container env, when present

## Start
```bash
cd /root/VizionAI/WORKSPACES/vizion-infra/containers/n8n
./run_with_infisical.sh
```

## What To Check
- `docker ps` shows both `n8n` and `n8n-runners`
- n8n UI loads at `http://127.0.0.1:32769`
- Code node executions succeed without falling back to an internal child runner

## Validation
1. Open n8n and run a simple Code node workflow.
2. Confirm the runner sidecar logs show the task being accepted.
3. Confirm the broker is listening only inside the compose network, not on a public host port.

## Rollback
```bash
cd /root/VizionAI/WORKSPACES/vizion-infra/containers/n8n
docker compose down
```

## Sources
- n8n task runner environment variables: https://docs.n8n.io/hosting/configuration/environment-variables/task-runners/
- n8n Docker setup: https://docs.n8n.io/hosting/installation/docker/
- n8n 2.0 breaking changes: https://docs.n8n.io/2-0-breaking-changes/
