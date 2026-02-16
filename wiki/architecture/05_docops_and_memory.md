# 05_docops_and_memory

This workspace owns the DocOps cycle—capture state, audit registries, regenerate durable memory, and publish the wiki/audit artifacts.

## DocOps cycle
- Entry point: `scripts/docops_run.sh`.
- Steps: `capture_system_state.sh` → `validate_workspace_structure.sh` → `audit_registry_consistency.sh` → `regenerate_memory.sh` → `wiki_sync.sh`.
- Each run appends a timestamped line to `state/docops_runs.log` and writes structured CSV/log reports under `state/`.
- Audit snapshots land in `wiki/audit/` (HTML, Markdown, logs) so stakeholders can inspect orchestration and runtime health.

## Memory regeneration
- `scripts/regenerate_memory.sh` re-creates every workspace `agents/main/MEMORY.md` from the authoritative registry CSV (`vizion-platform/registry/workspaces.csv`).
- The output highlights workspace roles, dependencies, and key constants (DB prefix, orchestrator, secrets vault).
- Regeneration runs inside DocOps and can be triggered independently when the registry or workspace topology changes.
