# HEARTBEAT.md - Infra Agent Periodic Checks

## Checks

### Wiki Freshness (daily)
- Check if any wiki page is older than 7 days without update
- Verify architecture diagrams match current container/port inventory
- Query: compare `wiki/audit/` timestamps with current date

### Workspace Structure Validation (daily)
- Run `validate_workspace_structure.sh` across all workspaces
- Verify each workspace has: agents/main/SOUL.md, AGENT.md, WORKSPACE.md
- Flag any workspace missing required files

### Registry Consistency (daily)
- Run `audit_registry_consistency.sh`
- Compare workspaces.csv with actual directories in /root/VizionAI/WORKSPACES/
- Check for orphaned or unregistered workspaces

### DocOps Cycle Status (weekly)
- Verify last DocOps run completed successfully
- Check MEMORY.md timestamps across all workspaces
- Verify GitHub Wiki is in sync with local wiki/

## Notify User When
- Wiki pages stale >7 days
- Workspace missing required agent files
- Registry drift detected (CSV vs actual)
- GitHub Wiki sync failure
- DocOps cycle failed

## Stay Quiet (HEARTBEAT_OK) When
- All wikis current
- All workspaces structurally valid
- Registry consistent
- Between 23:00-06:00 unless critical
