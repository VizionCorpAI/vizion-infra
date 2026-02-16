#!/usr/bin/env bash
set -euo pipefail

scope_type=${1:-system}
scope_key=${2:-system}
window_hours=${3:-168}

query_counts="select entry_type || ':' || count(*) from learning_entry group by entry_type order by entry_type;"
query_recent="select title from learning_entry where created_at >= now() - interval '${window_hours} hours' order by created_at desc limit 5;"

if [ "$scope_type" = "workspace" ]; then
  query_counts="select entry_type || ':' || count(*) from learning_entry where workspace_key = '$scope_key' group by entry_type order by entry_type;"
  query_recent="select title from learning_entry where workspace_key = '$scope_key' and created_at >= now() - interval '${window_hours} hours' order by created_at desc limit 5;"
fi

counts=$(/root/VizionAI/WORKSPACES/vizion-infra/scripts/psql_exec.sh -Atc "$query_counts" || true)
recent=$(/root/VizionAI/WORKSPACES/vizion-infra/scripts/psql_exec.sh -Atc "$query_recent" || true)

summary_md="## Learning Summary (${scope_type}:${scope_key})\n\n"
summary_md+="Window: last ${window_hours} hours\n\n"
summary_md+="Counts:\n"
if [ -n "$counts" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && summary_md+="- ${line}\n"
  done <<< "$counts"
else
  summary_md+="- none\n"
fi

summary_md+="\nRecent Entries:\n"
if [ -n "$recent" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && summary_md+="- ${line}\n"
  done <<< "$recent"
else
  summary_md+="- none\n"
fi

summary_md_escaped=$(printf "%s" "$summary_md" | sed "s/'/''/g")
source_query_escaped=$(printf "counts=%s; recent=%s" "$query_counts" "$query_recent" | sed "s/'/''/g")

insert_sql="INSERT INTO learn_summary (scope_type, scope_key, summary_md, source_query) VALUES ('$scope_type', '$scope_key', '$summary_md_escaped', '$source_query_escaped');"

/root/VizionAI/WORKSPACES/vizion-infra/scripts/psql_exec.sh -v ON_ERROR_STOP=1 -c "$insert_sql"

echo "learning_refresh_summary: wrote summary for ${scope_type}:${scope_key}"
