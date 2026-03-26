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

# ── Airtable Library: POST to Signals table ───────────────────────────────────
_airtable_token="${AIRTABLE_LIBRARY_TOKEN:-AIRTABLE_TOKEN_PLACEHOLDER}"
_airtable_base="${AIRTABLE_LIBRARY_BASE_ID:-appVnA7GVfUVfvBM0}"
if command -v curl >/dev/null 2>&1 && [ -n "$_airtable_token" ]; then
  _signal_body=$(python3 -c "
import json, sys
fields = {
  'source_type': '$(echo "$source_system" | sed "s/'/\\\\'/g")',
  'source_reference': '$(echo "$source_ref" | sed "s/'/\\\\'/g")',
  'workspace': '$(echo "${workspace:-vizion-infra}" | sed "s/'/\\\\'/g")',
  'severity': '$(echo "$severity" | sed "s/'/\\\\'/g")',
  'summary': '$(echo "$summary" | head -c 500 | sed "s/'/\\\\'/g")',
  'raw_content': '$(echo "$payload_json" | head -c 1000 | sed "s/'/\\\\'/g")',
  'status': 'unprocessed',
  'tags': '$(echo "$tags" | sed "s/'/\\\\'/g")',
}
print(json.dumps({'records': [{'fields': fields}]}))
" 2>/dev/null)
  if [ -n "$_signal_body" ]; then
    curl -s -X POST \
      -H "Authorization: Bearer $_airtable_token" \
      -H "Content-Type: application/json" \
      -d "$_signal_body" \
      "https://api.airtable.com/v0/$_airtable_base/Signals" >/dev/null 2>&1 && \
      echo "airtable: signal posted (fingerprint=$fingerprint)" || \
      echo "airtable: signal post failed (non-fatal)"
  fi
fi

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

  # ── Airtable Library: POST promoted entry as Article or Problem ─────────────
  _airtable_token="${AIRTABLE_LIBRARY_TOKEN:-AIRTABLE_TOKEN_PLACEHOLDER}"
  _airtable_base="${AIRTABLE_LIBRARY_BASE_ID:-appVnA7GVfUVfvBM0}"
  _at_table="Articles"
  _at_category="reference"
  case "$entry_type" in
    problem)         _at_table="Problems"; _at_category="general";;
    how_to)          _at_table="Articles"; _at_category="how-to";;
    recommendation)  _at_table="Recommendations"; _at_category="";;
    architecture)    _at_table="Articles"; _at_category="architecture";;
    *)               _at_table="Articles"; _at_category="reference";;
  esac

  if command -v curl >/dev/null 2>&1 && [ -n "$_airtable_token" ]; then
    _promoted_body=$(python3 -c "
import json
fields = {
  'title': '$(echo "$title" | head -c 255 | sed "s/\"/\\\\\"/g; s/'/\\\\x27/g")',
  'summary': '$(echo "$summary" | head -c 500 | sed "s/\"/\\\\\"/g; s/'/\\\\x27/g")',
  'status': 'draft',
  'source': '$(echo "$source_system" | sed "s/\"/\\\\\"/g")',
  'workspace': '$(echo "${workspace:-vizion-infra}" | sed "s/\"/\\\\\"/g")',
  'tags': '$(echo "$tags" | sed "s/\"/\\\\\"/g")',
  'created_by': 'learning_ingest',
}
$([ -n "$_at_category" ] && echo "fields['category'] = '$_at_category'" || echo "")
print(json.dumps({'records': [{'fields': fields}]}))
" 2>/dev/null)
    if [ -n "$_promoted_body" ]; then
      curl -s -X POST \
        -H "Authorization: Bearer $_airtable_token" \
        -H "Content-Type: application/json" \
        -d "$_promoted_body" \
        "https://api.airtable.com/v0/$_airtable_base/$_at_table" >/dev/null 2>&1 && \
        echo "airtable: promoted entry created in $_at_table" || \
        echo "airtable: promoted entry creation failed (non-fatal)"
    fi
  fi
fi
