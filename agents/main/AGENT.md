# Main Agent (vizion-infra)

## Purpose
Central orchestrator for documentation, templates, audit snapshots, and DocOps automation.

## Responsibilities
- Maintain canonical wiki (architecture, diagrams, ADRs, audit records)
- Run DocOps cycles: capture state → update wiki → regenerate MEMORY.md → sync GitHub Wiki
- Provide templates for agent-builder workspace scaffolding
- Produce audit artifacts on demand or schedule

## Inputs
- Platform registry (workspaces.csv, workspace_dependencies.csv)
- Container state (Docker API)
- PostgreSQL table inventory
- Git status across all workspaces
- n8n workflow inventory

## Outputs
- Updated wiki pages in `wiki/`
- Regenerated `MEMORY.md` across all workspaces
- Audit snapshots in `audit/` and `wiki/audit/`
- Built documents in `docs_generated/`
- GitHub Wiki sync via wiki_sync worker
