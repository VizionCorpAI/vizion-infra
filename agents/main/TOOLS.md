# TOOLS.md - Infra Agent Infrastructure

## Services
| Service    | Container Hostname                  | External Port | Notes                      |
|------------|-------------------------------------|---------------|----------------------------|
| OpenClaw   | openclaw-xbkt-openclaw-1:48950     | 48950         | This instance              |
| n8n        | n8n-hxq9-n8n-1:5678               | 32769         | Workflow automation        |
| PostgreSQL | postgresql-pv9y-postgresql-1:5432  | 32770         | Data storage               |
| GitHub     | github.com                          | 443           | Wiki sync target           |

## DB Connection
- Internal: `postgresql://VizionAI:YyFO4Qlo5gAUv4AM6UZFIj6uJGlrqwhu@postgresql-pv9y-postgresql-1:5432/AIDB`
- External: `postgresql://VizionAI:YyFO4Qlo5gAUv4AM6UZFIj6uJGlrqwhu@localhost:32770/AIDB`

## Wiki Locations
- Local: `wiki/` directory in this workspace
- GitHub: `VizionCorpAI/vizion-infra.wiki.git`

## n8n Workflows
| Workflow | ID | Trigger | Status |
|----------|----|---------|--------|
| DocOps Weekly | TBD | Weekly Sunday 02:00 | pending |
| Wiki Sync | TBD | On-demand / after DocOps | pending |
| Audit Snapshot Daily | TBD | Daily 05:00 | pending |
| Platform Tasks Consumer | TBD | Every 2 min | pending |

## Scripts
| Script | Purpose |
|--------|---------|
| capture_system_state.sh | Capture containers, ports, health, git status |
| generate_docx.sh | Build architecture DOCX from wiki markdown |
| audit_registry_consistency.sh | Check registry vs actual workspace state |
| validate_workspace_structure.sh | Verify all workspaces have required files |
| wiki_sync.sh | Push wiki/ to GitHub Wiki repo |
| docops_run.sh | Full DocOps cycle (capture → update → regenerate → sync) |
| regenerate_memory.sh | Regenerate MEMORY.md for all workspaces |
