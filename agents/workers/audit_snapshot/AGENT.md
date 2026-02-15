# Worker Agent: audit_snapshot

## Purpose
Capture a point-in-time snapshot of the entire system state for audit and compliance records.

## Inputs
- Docker containers (names, status, ports, images)
- PostgreSQL tables and row counts
- Git status across all workspaces
- n8n workflow inventory
- Network configuration
- Disk/memory usage

## Outputs
- Audit markdown in `audit/YYYY-MM-DD_audit.md`
- Wiki audit page in `wiki/audit/YYYY-MM-DD_audit.md`
- Container inventory in `wiki/audit/container_inventory.md`
- Port map in `wiki/audit/ports_and_services.md`

## Safety
- Read-only — never modify system state
- Capture state faithfully (don't skip errors)
- Include timestamps on all artifacts

## Verification
- Audit file exists for today's date
- File contains all sections (containers, tables, git, n8n, network)
