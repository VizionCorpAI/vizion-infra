#!/usr/bin/env bash
set -euo pipefail

# Validate workspace directory structure against canonical standard.
# Checks each registered workspace for required dirs/files.

cd "$(dirname "$0")/.."

WORKSPACES_DIR="/root/VizionAI/WORKSPACES"
REGISTRY="$WORKSPACES_DIR/vizion-platform/registry/workspaces.csv"
REPORT_FILE="state/validate_structure_$(date -u +%Y%m%dT%H%M%SZ).log"
mkdir -p state

REQUIRED_DIRS=(agents agents/main agents/workers scripts)
REQUIRED_FILES=(WORKSPACE.md agents/main/AGENT.md)
OPTIONAL_FILES=(agents/main/SOUL.md agents/main/MEMORY.md agents/main/TOOLS.md)

total=0
passed=0
issues=0

{
  echo "=== Workspace Structure Validation $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
  echo ""

  if [ ! -f "$REGISTRY" ]; then
    echo "ERROR: Registry not found at $REGISTRY"
    exit 1
  fi

  tail -n +2 "$REGISTRY" | while IFS=, read -r ws_key agent_key repo_name repo_path _rest; do
    total=$((total + 1))
    ws_issues=0
    echo "--- $ws_key ($repo_path) ---"

    if [ ! -d "$repo_path" ]; then
      echo "  FAIL: directory does not exist"
      issues=$((issues + 1))
      continue
    fi

    for d in "${REQUIRED_DIRS[@]}"; do
      if [ ! -d "$repo_path/$d" ]; then
        echo "  MISSING DIR: $d"
        ws_issues=$((ws_issues + 1))
      fi
    done

    for f in "${REQUIRED_FILES[@]}"; do
      if [ ! -f "$repo_path/$f" ]; then
        echo "  MISSING FILE: $f"
        ws_issues=$((ws_issues + 1))
      fi
    done

    missing_optional=()
    for f in "${OPTIONAL_FILES[@]}"; do
      [ -f "$repo_path/$f" ] || missing_optional+=("$f")
    done
    [ "${#missing_optional[@]}" -gt 0 ] && echo "  OPTIONAL MISSING: ${missing_optional[*]}"

    # Check scripts dir has at least psql_exec.sh
    if [ -d "$repo_path/scripts" ]; then
      script_count=$(find "$repo_path/scripts" -name "*.sh" -type f 2>/dev/null | wc -l)
      echo "  scripts: $script_count .sh files"
    fi

    # Check git status
    if [ -d "$repo_path/.git" ]; then
      branch=$(git -C "$repo_path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
      dirty=$(git -C "$repo_path" status --porcelain 2>/dev/null | wc -l)
      echo "  git: branch=$branch dirty=$dirty"
    else
      echo "  git: NOT a git repo"
    fi

    if [ "$ws_issues" -eq 0 ]; then
      echo "  STATUS: OK"
      passed=$((passed + 1))
    else
      echo "  STATUS: $ws_issues issues"
      issues=$((issues + ws_issues))
    fi
    echo ""
  done

  echo "=== Summary ==="

} 2>&1 | tee "$REPORT_FILE"

echo "Report: $REPORT_FILE"
