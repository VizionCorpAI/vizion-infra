# Ingest

Intake mapping from alerts, analytics, or maintenance into learning entries.
Use to record source ids and the resulting learning entry ids.

## Promotion Rules
See `promotion_rules.yaml` for signal dedupe and promotion thresholds.

## Ingest Script
`/root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_ingest.sh`

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

## Promotion Job
`/root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_promote.sh` applies the promotion thresholds
defined in `promotion_rules.yaml`.
