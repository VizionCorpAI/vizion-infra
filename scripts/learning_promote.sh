#!/usr/bin/env bash
set -euo pipefail

# Promote learn_signal rows to learning_entry based on thresholds.
# Thresholds mirror learning/ingest/promotion_rules.yaml.

PROMOTE_SEVERITIES=${PROMOTE_SEVERITIES:-"high,critical"}
THRESHOLD_A_COUNT=${THRESHOLD_A_COUNT:-3}
THRESHOLD_A_HOURS=${THRESHOLD_A_HOURS:-24}
THRESHOLD_B_COUNT=${THRESHOLD_B_COUNT:-5}
THRESHOLD_B_HOURS=${THRESHOLD_B_HOURS:-168}
DEFAULT_ENTRY_TYPE=${DEFAULT_ENTRY_TYPE:-problem}
DEFAULT_STATUS=${DEFAULT_STATUS:-open}
DEFAULT_SEVERITY=${DEFAULT_SEVERITY:-medium}

sql=$(cat <<SQL
WITH candidates AS (
  SELECT s.*
  FROM learn_signal s
  LEFT JOIN learn_link l
    ON l.link_type = 'signal' AND l.link_key = s.fingerprint
  WHERE l.id IS NULL
    AND (
      s.severity = ANY(string_to_array(:'promote_severities', ','))
      OR (s.seen_count >= :'threshold_a_count' AND s.last_seen >= now() - (:'threshold_a_hours' || ' hours')::interval)
      OR (s.seen_count >= :'threshold_b_count' AND s.last_seen >= now() - (:'threshold_b_hours' || ' hours')::interval)
    )
)
INSERT INTO learn_link (entry_id, link_type, link_key, link_meta)
SELECT
  e.id,
  'signal',
  c.fingerprint,
  jsonb_build_object('source_system', c.source_system)
FROM candidates c
CROSS JOIN LATERAL (
  INSERT INTO learning_entry (entry_type, title, summary, details, workspace_key, source_system, source_ref, severity, status, tags)
  VALUES (
    :'entry_type',
    COALESCE(c.title, c.summary, 'Signal ' || c.fingerprint),
    c.summary,
    NULL,
    NULLIF((c.payload->>'workspace'), ''),
    c.source_system,
    c.source_ref,
    COALESCE(c.severity, :'default_severity'),
    :'default_status',
    NULL
  )
  RETURNING id
) e;
SQL
)

/root/VizionAI/WORKSPACES/vizion-infra/scripts/psql_exec.sh \
  -v promote_severities="$PROMOTE_SEVERITIES" \
  -v threshold_a_count="$THRESHOLD_A_COUNT" \
  -v threshold_a_hours="$THRESHOLD_A_HOURS" \
  -v threshold_b_count="$THRESHOLD_B_COUNT" \
  -v threshold_b_hours="$THRESHOLD_B_HOURS" \
  -v entry_type="$DEFAULT_ENTRY_TYPE" \
  -v default_status="$DEFAULT_STATUS" \
  -v default_severity="$DEFAULT_SEVERITY" \
  <<< "$sql"

echo "learning_promote: promotion run complete"

# ── Airtable Library: sync promoted entries to Signals (mark as promoted) ─────
_airtable_token="${AIRTABLE_LIBRARY_TOKEN:-AIRTABLE_TOKEN_PLACEHOLDER}"
_airtable_base="${AIRTABLE_LIBRARY_BASE_ID:-appVnA7GVfUVfvBM0}"
if command -v curl >/dev/null 2>&1 && [ -n "$_airtable_token" ]; then
  # Fetch unprocessed signals from Airtable, promote them to 'promoted' status
  _unprocessed=$(curl -s \
    -H "Authorization: Bearer $_airtable_token" \
    "https://api.airtable.com/v0/$_airtable_base/Signals?filterByFormula=status='unprocessed'&pageSize=50" 2>/dev/null)

  _count=$(echo "$_unprocessed" | python3 -c "
import sys, json
d = json.load(sys.stdin)
recs = d.get('records', [])
print(len(recs))
" 2>/dev/null || echo "0")

  if [ "$_count" -gt 0 ] 2>/dev/null; then
    # Build bulk patch payload for all unprocessed signals → status=in-review
    _patch_body=$(echo "$_unprocessed" | python3 -c "
import sys, json
d = json.load(sys.stdin)
records = [{'id': r['id'], 'fields': {'status': 'in-review'}} for r in d.get('records', [])]
print(json.dumps({'records': records[:10]}))  # Airtable max 10 per batch
" 2>/dev/null)
    if [ -n "$_patch_body" ]; then
      curl -s -X PATCH \
        -H "Authorization: Bearer $_airtable_token" \
        -H "Content-Type: application/json" \
        -d "$_patch_body" \
        "https://api.airtable.com/v0/$_airtable_base/Signals" >/dev/null 2>&1 && \
        echo "airtable: $_count unprocessed signals moved to in-review" || \
        echo "airtable: signals update failed (non-fatal)"
    fi
  else
    echo "airtable: no unprocessed signals to promote"
  fi
fi
