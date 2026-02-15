# BOOTSTRAP.md

## Startup Checklist
1. Read `AGENT.md`, `SOUL.md`, `TOOLS.md`, `HEARTBEAT.md`.
2. Resolve workspace key and dependencies from platform registry tables.
3. Verify wiki/ directory has current architecture docs.
4. Check last DocOps run timestamp in state/.
5. Verify GitHub Wiki remote is configured.
6. Emit events to alert-reporting for any anomalies or failed tasks.

## Operating Rules
- Prefer making changes via this workspace's scripts and workflows.
- When a task affects multiple workspaces, route via platform tasks and scheduler jobs.
- DocOps cycle: capture → update wiki → regenerate MEMORY.md → sync GitHub Wiki.
- All changes to wiki pages should be logged to sec_audit_log via alert-reporting.
