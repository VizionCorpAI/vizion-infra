#!/usr/bin/env bash
set -euo pipefail

/root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_refresh_summary.sh system system 168

workspaces=$(/root/VizionAI/WORKSPACES/vizion-infra/scripts/psql_exec.sh -Atc "select distinct workspace_key from learning_entry where workspace_key is not null and workspace_key <> '' order by workspace_key;" || true)
if [ -n "$workspaces" ]; then
  while IFS= read -r ws; do
    [ -n "$ws" ] && /root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_refresh_summary.sh workspace "$ws" 168
  done <<< "$workspaces"
fi

echo "learning_refresh_all_summaries: complete"
