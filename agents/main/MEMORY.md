# MEMORY.md

This file stores durable workspace memory (high-level, non-sensitive).

## Facts
- Central orchestrator: `vizion-scheduling`
- Event bus: `vizion-alert-reporting` (Postgres `alert_event`)
- Registry authority: `vizion-platform`
- Secrets vault: Infisical (SaaS) via Universal Auth
- Documentation authority: `vizion-infra` (this workspace)

## Workspaces (10 total)
- vizion-trading, vizion-marketing, vizion-analytics, vizion-scheduling
- vizion-alert-reporting, vizion-maintenance, vizion-agent-builder
- vizion-platform, vizion-security, vizion-infra

## Key Paths
- Wiki: `/root/VizionAI/WORKSPACES/vizion-infra/wiki/`
- Templates: `/root/VizionAI/WORKSPACES/vizion-infra/templates/`
- Registry: `/root/VizionAI/WORKSPACES/vizion-platform/registry/`

## Notes
- Do not put secrets here.
- PostgreSQL port is 32770 (external), 5432 (internal Docker network).
- GitHub Wiki: VizionCorpAI/vizion-infra.wiki.git
