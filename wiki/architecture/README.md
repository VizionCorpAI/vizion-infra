# VizionAI Architecture

This is the canonical system architecture landing page for VizionAI.
It describes how the workspaces, services, secrets, workflows, and shared memory fit together as of `2026-03-30`.

It is intended to be used by humans, agents, workflows, and system services.

For deeper chapter-style notes, see `../learning/architecture/`.

## System Layers

### 1. Control Plane
- `vizion-platform`
- Owns the workspace registry, dependency graph, runtime sync, and task dispatch conventions.
- Keeps the workspace inventory, agent registry, and workflow registry aligned.

### 2. Execution Plane
- `n8n`
- `OpenClaw`
- `crawl4ai`
- Workspace helper scripts
- Executes recurring jobs, capture flows, browser actions, imports, approvals, and queue processing.

### 3. Secrets and Policy Plane
- `vizion-security`
- Infisical project: `vizion-infrastructure`
- Owns secret layout, machine identities, compliance policy, audit guardrails, and rotation standards.

### 4. Memory Plane
- `vizion-infra`
- Learning plane, audit snapshots, verified how-tos, architecture notes, and operational memory.
- Airtable mirror receives compact summaries and links, not raw dumps.

### 5. Domain Workspaces
- `vizion-trading`
- `vizion-analytics`
- `vizion-marketing`
- `vizion-onboarding`
- `vizion-scheduling`
- `vizion-alert-reporting`
- `vizion-maintenance`
- `vizion-input-output`

Each domain workspace owns its own logic and emits compact state to the shared layers.

## Current Runtime Topology

- OpenClaw UI: `0.0.0.0:48950`
- n8n editor/API: `0.0.0.0:32769`
- n8n task runners: internal sidecar, no host port
- PostgreSQL AIDB: `0.0.0.0:32770`
- NN server: `vizion-nn.service` on `:8000`
- Scheduler: `vizion-scheduling-runner.timer`
- crawl4ai: containerized public-page capture service used by `vizion-input-output`

## How The Pieces Work Together

1. A request enters through OpenClaw, n8n, a webhook, a scheduled job, or a helper script.
2. `vizion-platform` routes the request to the correct workspace or task queue.
3. `vizion-security` supplies the secret and policy boundaries for the action.
4. `n8n` handles recurring execution, webhook intake, API glue, and queue processing.
5. `OpenClaw` handles login-gated browsing, form completion, and bounded browser actions.
6. `crawl4ai` captures and normalizes public pages before any interactive step is needed.
7. Postgres stores shared operational state, workflow records, and queue artifacts.
8. `vizion-infra` records the durable memory of what happened and why.

## Workspace Responsibilities

| Workspace | Primary Role | Typical Inputs | Typical Outputs |
|---|---|---|---|
| `vizion-platform` | Registry, routing, dispatch, sync | Workspace metadata, task state, normalized events | Registry updates, dispatch metadata, task routing |
| `vizion-security` | Secrets, policy, compliance, guardrails | Infisical state, auth events, policy reviews, scan results | Policy checks, audit logs, compliance attestations |
| `vizion-infra` | Canonical handbook and memory | Audit snapshots, state captures, docs, runbooks | Learning entries, wiki updates, operating notes |
| `vizion-input-output` | Shared capture and filing front door | URLs, forms, leads, opportunities, uploads | Normalized records, filing drafts, submissions, shared outputs |
| `vizion-alert-reporting` | Alert intake and fanout | Alerts, snapshots, workflow failures | Alert events, summaries, downstream notifications |
| `vizion-scheduling` | Recurring timing and retries | Cron rules, schedules, dispatch state | Due jobs, follow-up tasks, repeat triggers |
| `vizion-maintenance` | Hygiene and cleanup | Host state, workspace health, audit findings | Cleanup actions, repair tasks, audit reports |
| `vizion-analytics` | Rollups and evaluation | Task history, trade history, metrics, alert data | KPI rollups, anomaly signals, reports |
| `vizion-trading` | Trading and execution support | Market data, MT5 state, NN signals, trade history | Trade ops outputs, signals, evaluations |
| `vizion-marketing` | Content, leads, CRM | Lead data, content topics, social metrics | Campaign actions, social output, CRM updates |
| `vizion-onboarding` | New client/workspace setup | Onboarding requests, templates, credentials | Setup actions, validation output, provisioning state |

## Secret Flow

- All secrets live in Infisical.
- Runtime services should read from scoped paths instead of hardcoding credentials.
- The n8n runtime uses the infrastructure project, especially `/platform/n8n`.
- OpenClaw uses its own scoped secret path.
- Domain secrets stay within the owning workspace or business project.
- No repo should contain plaintext secrets.

## Current n8n State

- The `vizion-input-output` workflow set is imported and active in the live n8n instance.
- The active flows are:
  - `wf_io_manual_intake`
  - `wf_io_capture_normalize_5m`
  - `wf_io_route_queue_10m`
  - `wf_io_submission_preflight_30m`
  - `wf_io_publish_shared_1h`
- These workflows are exported with `availableInMCP: true` so they remain visible to the MCP-first tooling pattern.

## Current OpenClaw State

- Workspace skills are generated from `WORKSPACES/*/agents/**/AGENT.md`.
- Synced skills are stored under `/docker/openclaw-xbkt/data/skills`.
- OpenClaw is used for browser actions, form filling, review steps, and bounded submissions.

## Current Input/Output State

- `crawl4ai` is the public capture engine for pages that do not require login.
- `vizion-input-output/scripts/capture_public.sh` captures a URL, stores normalized records in Postgres, and produces a compact JSON summary.
- The shared input/output workspace is the front door for future job applications, contract work, grant applications, and business lead filing.

## Current Memory State

- Detailed architecture chapters live in `../learning/architecture/`.
- The learning plane is the durable memory layer for verified notes, state snapshots, and how-to guidance.
- The wiki audit archive holds timestamped runtime snapshots and operational history.

## Canonical References

- `../../README.md`
- `../learning/README.md`
- `../learning/architecture/README.md`
- `../learning/architecture/workspace_responsibility_matrix.md`
- `../learning/architecture/05_docops_and_memory.md`
- `../learning/architecture/07_workspace_model.md`
- Security policy manifest: `../../vizion-security/docs/POLICY_INDEX.json`
- Security policy index: `../../vizion-security/docs/POLICY_INDEX.md`
