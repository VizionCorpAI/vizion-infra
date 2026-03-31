# Ingest

Intake mapping from alerts, analytics, or maintenance into learning entries.
Use to record source ids and the resulting learning entry ids.

## Promotion Rules
See `promotion_rules.yaml` for signal dedupe and promotion thresholds.

## Ingest Script
`/root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_ingest.sh`

## Issue Reporter
Use the shared reporter when OpenClaw, n8n, Codex, Claude Code, or any other workspace tool hits a bug or operational issue:
`/root/VizionAI/WORKSPACES/vizion-infra/scripts/report_learning_issue.sh`

Convenience wrappers:
- `/root/VizionAI/WORKSPACES/vizion-infra/scripts/report_openclaw_issue.sh`
- `/root/VizionAI/WORKSPACES/vizion-infra/scripts/report_n8n_issue.sh`
- `/root/VizionAI/WORKSPACES/vizion-infra/scripts/report_codex_issue.sh`
- `/root/VizionAI/WORKSPACES/vizion-infra/scripts/report_claudecode_issue.sh`

Example:
```bash
./scripts/learning_ingest.sh \
  --fingerprint "maintenance:drift:docker-ports" \
  --source-system maintenance \
  --summary "Docker ports drifted from registry" \
  --severity high \
  --workspace infra \
  --payload '{"ports":[443,80]}' \
  --tags "maintenance,drift" \
  --promote
```

Issue example:
```bash
./scripts/report_openclaw_issue.sh \
  --title "Telegram bot stopped responding" \
  --summary "OpenClaw returned 404 on /responses and did not reply." \
  --root-cause "Manual google provider config pointed to openai-responses." \
  --fix "Remove the google provider block and restart OpenClaw." \
  --tags "openclaw,telegram,gemini"
```

## Promotion Job
`/root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_promote.sh` applies the promotion thresholds
defined in `promotion_rules.yaml`.
