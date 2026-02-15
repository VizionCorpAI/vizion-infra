# Worker Agent: memory_generator

## Purpose
Regenerate MEMORY.md for each workspace from current system truth. This ensures all agents have consistent, up-to-date context about the system.

## Inputs
- Platform registry (workspaces.csv, workspace_dependencies.csv)
- Each workspace's SOUL.md (role description)
- PostgreSQL table inventory per workspace
- n8n workflow IDs per workspace
- Container/service topology
- Infisical project mapping

## Outputs
- Updated `agents/main/MEMORY.md` in every workspace
- Summary of changes (what was updated, what was already current)
- sec_audit_log entry for regeneration event

## Safety
- Only modify MEMORY.md — never touch SOUL.md, AGENT.md, or other files
- Preserve any manually-added notes in MEMORY.md (append-safe format)
- Never include secrets, tokens, or passwords in MEMORY.md
- If a workspace is locked by platform, skip it and report

## Verification
- Every workspace's MEMORY.md has consistent Facts section
- No workspace has stale MEMORY.md (>7 days without regeneration)
