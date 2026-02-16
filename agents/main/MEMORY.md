# MEMORY.md

This file stores durable workspace memory (high-level, non-sensitive).
Last regenerated: 2026-02-16T01:07:07Z

## Facts
- Central orchestrator: `vizion-scheduling`
- Event bus: `vizion-alert-reporting` (Postgres `alert_event`)
- Registry authority: `vizion-platform`
- Secrets vault: Infisical (SaaS) via Universal Auth
- Documentation authority: `vizion-infra`

## This Workspace
- Key: `infra`
- Agent: `infra`
- Role: Infrastructure & Documentation Agent
- DB prefix: `infra_`
- Dependencies: none

## Notes
- Do not put secrets here.
- PostgreSQL port is 32770 (external), 5432 (internal Docker network).
