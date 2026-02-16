#!/usr/bin/env bash
set -euo pipefail

# Audit registry consistency: filesystem ↔ platform CSV ↔ DB ↔ OpenClaw skills.

cd "$(dirname "$0")/.."

WORKSPACES_DIR="/root/VizionAI/WORKSPACES"
SKILLS_DIR="/docker/openclaw-xbkt/data/skills"
REGISTRY="$WORKSPACES_DIR/vizion-platform/registry/workspaces.csv"
DEPS="$WORKSPACES_DIR/vizion-platform/registry/workspace_dependencies.csv"
REPORT_FILE="state/audit_registry_$(date -u +%Y%m%dT%H%M%SZ).log"
PSQL="$WORKSPACES_DIR/vizion-infra/scripts/psql_exec.sh"

mkdir -p state

{
  echo "=== Registry Consistency Audit $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
  echo ""

  # 1. Filesystem workspaces
  echo "--- Filesystem Workspaces ---"
  fs_ws=()
  while IFS= read -r d; do
    ws=$(basename "$d")
    fs_ws+=("$ws")
    echo "  $ws"
  done < <(find "$WORKSPACES_DIR" -maxdepth 1 -mindepth 1 -type d -name "vizion-*" | sort)
  echo "  Total: ${#fs_ws[@]}"
  echo ""

  # 2. CSV registry
  echo "--- CSV Registry ---"
  csv_keys=()
  csv_repos=()
  if [ -f "$REGISTRY" ]; then
    while IFS=, read -r ws_key agent_key repo_name repo_path _rest; do
      csv_keys+=("$ws_key")
      csv_repos+=("$repo_name")
      echo "  $ws_key -> $repo_name ($repo_path)"
    done < <(tail -n +2 "$REGISTRY")
  else
    echo "  ERROR: Registry not found"
  fi
  echo "  Total: ${#csv_keys[@]}"
  echo ""

  # 3. DB registry
  echo "--- DB Registry (workspace_repo_registry) ---"
  db_ws=()
  if [ -x "$PSQL" ]; then
    mapfile -t db_rows < <("$PSQL" -Atq -c "SELECT workspace_key FROM workspace_repo_registry ORDER BY workspace_key;" 2>/dev/null || true)
    for r in "${db_rows[@]}"; do
      [ -n "$r" ] && db_ws+=("$r") && echo "  $r"
    done
  else
    echo "  WARN: psql_exec.sh not available"
  fi
  echo "  Total: ${#db_ws[@]}"
  echo ""

  # 4. Skills directory
  echo "--- OpenClaw Skills ---"
  skill_ws=()
  while IFS= read -r d; do
    ws=$(basename "$d")
    skill_ws+=("$ws")
    echo "  $ws"
  done < <(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort)
  echo "  Total: ${#skill_ws[@]}"
  echo ""

  # 5. Cross-reference
  echo "--- Cross-Reference Issues ---"
  issues=0

  for repo in "${csv_repos[@]}"; do
    found=false
    for s in "${skill_ws[@]}"; do [ "$s" = "$repo" ] && found=true && break; done
    $found || { echo "  CSV→SKILL MISSING: $repo not in OpenClaw skills"; issues=$((issues+1)); }
  done

  for s in "${skill_ws[@]}"; do
    found=false
    for ws in "${fs_ws[@]}"; do [ "$ws" = "$s" ] && found=true && break; done
    $found || echo "  EXTRA SKILL: $s (no matching workspace dir — may be standalone)"
  done

  # DB vs CSV
  if [ "${#db_ws[@]}" -gt 0 ]; then
    for d in "${db_ws[@]}"; do
      found=false
      for c in "${csv_keys[@]}"; do [ "$c" = "$d" ] && found=true && break; done
      $found || echo "  DB→CSV MISSING: $d in DB but not CSV"
    done
    for c in "${csv_keys[@]}"; do
      found=false
      for d in "${db_ws[@]}"; do [ "$d" = "$c" ] && found=true && break; done
      $found || echo "  CSV→DB MISSING: $c in CSV but not DB"
    done
  fi

  # Dependencies check
  echo ""
  echo "--- Dependency Validation ---"
  if [ -f "$DEPS" ]; then
    dep_count=$(tail -n +2 "$DEPS" 2>/dev/null | wc -l)
    echo "  Dependencies: $dep_count entries"
    echo "  Dependencies file validated."
  else
    echo "  WARN: Dependencies file not found"
  fi

  echo ""
  echo "=== Issues found: $issues ==="

} 2>&1 | tee "$REPORT_FILE"

echo "Report: $REPORT_FILE"
