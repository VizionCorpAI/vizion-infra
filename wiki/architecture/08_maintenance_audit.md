# 08_maintenance_audit

This is the maintenance audit system: a DocOps-driven feedback loop that captures the live stack, validates every workspace, and publishes the results in the `wiki/audit/` archive.

## Goal
- Provide a single, trusted snapshot of orchestration state, Docker containers, ports, services, memory size, packages, and raft of workspace metadata.
- Keep the canonical wiki in sync with what is actually running on the host, so maintenance can rapidly triage drift.

## Key components
- `scripts/capture_system_state.sh`: gathers host metadata, services, timers, docker status, logs, and package inventory, then invokes `scripts/generate_architecture_audit.sh` to render the HTML audit plus supporting markdown.
- `scripts/docops_run.sh`: orchestrates the capture step, validates workspace structure, audits registry consistency, regenerates `MEMORY.md`, and runs `scripts/wiki_sync.sh` to push the markdown into the GitHub wiki.
- `state/`: stores audit reports (`state/validate_structure_*.log`, `state/audit_registry_*.log`), `docops_runs.log`, and the `client_channels.json` ledger used by OpenClaw onboarding helpers.
- `wiki/audit/`: houses timestamped HTML/Markdown snapshots and container/port inventories that DocOps regenerates every run.

## Automation flow
1. Maintenance triggers `docops_run.sh` manually or via the `vizion-infra` `wf_docops_weekly` workflow. The capture step writes `wiki/audit/<date>_audit.html` and small supporting markdown for quick reading.
2. The validation step checks each workspace’s scripts folder and git cleanliness, while the registry audit cross-references the filesystem, platform CSV, and OpenClaw skills.
3. Regenerating `MEMORY.md` keeps workspace memory files truthful, so the agent catalogs always expose accurate roles, dependencies, and key constants.
4. Wiki sync copies the flat markdown into `state/wiki-clone` for GitHub, so a single command can fetch the latest architecture doc plus audit snapshot.

By packaging these pieces, the maintenance audit system minimizes manual list-building and makes every deployment traceable.
