#!/usr/bin/env bash
set -euo pipefail

# Regenerate MEMORY.md for all workspaces from system truth.
# Usage: ./scripts/regenerate_memory.sh

cd "$(dirname "$0")/.."

WORKSPACES_DIR="/root/VizionAI/WORKSPACES"
REGISTRY="${WORKSPACES_DIR}/vizion-platform/registry/workspaces.csv"
DEPS="${WORKSPACES_DIR}/vizion-platform/registry/workspace_dependencies.csv"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "=== Regenerate MEMORY.md ($TIMESTAMP) ==="

# Read workspace list from registry
if [ ! -f "$REGISTRY" ]; then
  echo "ERROR: Registry not found at $REGISTRY" >&2
  exit 1
fi

UPDATED=0
SKIPPED=0

# Process each workspace (skip header line)
tail -n +2 "$REGISTRY" | while IFS=, read -r ws_key agent_key repo_name repo_path repo_remote wf_ns db_name db_schema db_prefix status; do
  [ "$status" != "active" ] && continue

  MEMORY_FILE="${repo_path}/agents/main/MEMORY.md"
  SOUL_FILE="${repo_path}/agents/main/SOUL.md"

  # Skip if agents/main/ doesn't exist
  if [ ! -d "${repo_path}/agents/main" ]; then
    echo "  SKIP: $ws_key (no agents/main/)"
    SKIPPED=$((SKIPPED+1))
    continue
  fi

  # Extract role from SOUL.md if it exists
  ROLE="(role not defined)"
  if [ -f "$SOUL_FILE" ]; then
    ROLE=$(head -1 "$SOUL_FILE" | sed 's/^# SOUL.md - //')
  fi

  # Get dependencies
  DEPS_LIST=""
  if [ -f "$DEPS" ]; then
    DEPS_LIST=$(grep "^${ws_key}," "$DEPS" 2>/dev/null | cut -d, -f2 | sort -u | tr '\n' ', ' | sed 's/,$//')
  fi

  cat > "$MEMORY_FILE" << MEMEOF
# MEMORY.md

This file stores durable workspace memory (high-level, non-sensitive).
Last regenerated: ${TIMESTAMP}

## Facts
- Central orchestrator: \`vizion-scheduling\`
- Event bus: \`vizion-alert-reporting\` (Postgres \`alert_event\`)
- Registry authority: \`vizion-platform\`
- Secrets vault: Infisical (SaaS) via Universal Auth
- Documentation authority: \`vizion-infra\`

## This Workspace
- Key: \`${ws_key}\`
- Agent: \`${agent_key}\`
- Role: ${ROLE}
- DB prefix: \`${db_prefix}\`
- Dependencies: ${DEPS_LIST:-none}

## Notes
- Do not put secrets here.
- PostgreSQL port is 32770 (external), 5432 (internal Docker network).
MEMEOF

  echo "  OK: $ws_key"
  UPDATED=$((UPDATED+1))
done

echo ""
echo "=== Done. Updated: $UPDATED, Skipped: $SKIPPED ==="
