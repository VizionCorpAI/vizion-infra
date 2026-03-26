# OpenClaw Automation

## Safety Boundaries
- Only allowlisted tasks are executed
- Workspace skills are generated from `WORKSPACES/*/agents/**/AGENT.md`
- OpenClaw skill sync targets `/docker/openclaw-xbkt/data/skills`

## Dispatch Model
- Platform emits `platform_task`
- Scheduler triggers workspace workflows or OpenClaw skills
