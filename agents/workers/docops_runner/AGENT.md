# Worker Agent: docops_runner

## Purpose
Execute the full DocOps cycle: capture system state, update wiki pages, regenerate MEMORY.md across all workspaces, build docs artifacts, and trigger wiki sync.

## Inputs
- Current system state (containers, ports, git, DB)
- Platform registry (workspaces.csv, workspace_dependencies.csv)
- All workspace SOUL.md and TOOLS.md files

## Outputs
- Updated wiki/ architecture pages
- Regenerated MEMORY.md in every workspace's agents/main/
- Audit snapshot artifact in audit/ and wiki/audit/
- Built DOCX in docs_generated/
- Trigger for wiki_sync worker

## Safety
- Read-only from other workspaces (never modify their code or logic files)
- Only write MEMORY.md to other workspaces (controlled, documented format)
- Log all DocOps runs to sec_audit_log via alert-reporting
- If any step fails, complete remaining steps and report partial success

## Verification
- Every workspace has a MEMORY.md with today's date reference
- wiki/ pages updated within last 7 days
- docs_generated/ artifact exists and is current
