#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 \
  --fingerprint <id> \
  --source-system <system> \
  --summary <text> \
  [--title <text>] \
  [--severity <low|medium|high|critical>] \
  [--workspace <key>] \
  [--source-ref <ref>] \
  [--payload <json>] \
  [--tags <comma,separated>] \
  [--entry-type <problem|how_to|recommendation|state|architecture|other>] \
  [--promote]

Notes:
- Inserts/updates learn_signal.
- If --promote is set, creates a learning_entry and links it.
USAGE
  exit 1
}

fingerprint=""
source_system=""
summary=""
title=""
severity=""
workspace=""
source_ref=""
payload="{}"
tags=""
entry_type=""
promote="false"

while [ $# -gt 0 ]; do
  case "$1" in
    --fingerprint) fingerprint="$2"; shift 2;;
    --source-system) source_system="$2"; shift 2;;
    --summary) summary="$2"; shift 2;;
    --title) title="$2"; shift 2;;
    --severity) severity="$2"; shift 2;;
    --workspace) workspace="$2"; shift 2;;
    --source-ref) source_ref="$2"; shift 2;;
    --payload) payload="$2"; shift 2;;
    --tags) tags="$2"; shift 2;;
    --entry-type) entry_type="$2"; shift 2;;
    --promote) promote="true"; shift 1;;
    *) usage;;
  esac
 done

[ -z "$fingerprint" ] && usage
[ -z "$source_system" ] && usage
[ -z "$summary" ] && usage

if [ -z "$title" ]; then
  title="$summary"
fi

if [ -z "$severity" ]; then
  severity="medium"
fi

if [ -z "$entry_type" ]; then
  entry_type="problem"
fi

if command -v jq >/dev/null 2>&1; then
  if ! printf '%s' "$payload" | jq -e . >/dev/null 2>&1; then
    payload="{}"
  fi
fi

payload_json="$payload"

sql=$(cat <<'SQL'
INSERT INTO learn_signal (fingerprint, source_system, source_ref, severity, title, summary, payload)
VALUES (:'fingerprint', :'source_system', :'source_ref', :'severity', :'title', :'summary', (:'payload')::jsonb)
ON CONFLICT (fingerprint) DO UPDATE
SET last_seen = now(),
    seen_count = learn_signal.seen_count + 1,
    summary = COALESCE(EXCLUDED.summary, learn_signal.summary),
    payload = learn_signal.payload || EXCLUDED.payload;
SQL
)

/root/VizionAI/WORKSPACES/vizion-infra/scripts/psql_exec.sh \
  -v fingerprint="$fingerprint" \
  -v source_system="$source_system" \
  -v source_ref="$source_ref" \
  -v severity="$severity" \
  -v title="$title" \
  -v summary="$summary" \
  -v payload="$payload_json" \
  <<< "$sql"

echo "learn_signal upserted for fingerprint=$fingerprint"

if [ "$promote" = "true" ]; then
  promote_sql=$(cat <<'SQL'
WITH new_entry AS (
  INSERT INTO learning_entry (entry_type, title, summary, details, workspace_key, source_system, source_ref, severity, tags)
  VALUES (:'entry_type', :'title', :'summary', NULL, :'workspace', :'source_system', :'source_ref', :'severity', string_to_array(:'tags', ','))
  RETURNING id
)
INSERT INTO learn_link (entry_id, link_type, link_key, link_meta)
SELECT id, 'signal', :'fingerprint', jsonb_build_object('source_system', :'source_system')
FROM new_entry;
SQL
)

  /root/VizionAI/WORKSPACES/vizion-infra/scripts/psql_exec.sh \
    -v entry_type="$entry_type" \
    -v title="$title" \
    -v summary="$summary" \
    -v workspace="$workspace" \
    -v source_system="$source_system" \
    -v source_ref="$source_ref" \
    -v severity="$severity" \
    -v tags="$tags" \
    -v fingerprint="$fingerprint" \
    <<< "$promote_sql"

  echo "learning_entry created and linked"
fi
