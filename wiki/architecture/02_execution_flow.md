# Orchestration

## Central Scheduler (single orchestrator)
- Systemd timer: `vizion-scheduling-runner.timer`
- Jobs: `sched_job` and `sched_job_run`

## Flow
1. Alert reporting collects snapshots
2. Scheduler runs `platform.plan_dispatch`
3. Platform emits `platform_task` → `alert_event`
4. Scheduler consumes platform tasks and triggers workspace actions
5. Maintenance consumes tasks and runs allowlisted actions
