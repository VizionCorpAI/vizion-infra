#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 \
  --source-system <openclaw|n8n|codex|claudecode|other> \
  --title <text> \
  --summary <text> \
  [--workspace <key>] \
  [--source-ref <ref>] \
  [--severity <low|medium|high|critical>] \
  [--tags <comma,separated>] \
  [--root-cause <text>] \
  [--fix <text>] \
  [--solution <text>] \
  [--details <text>] \
  [--affected-services <comma,separated>] \
  [--entry-type <problem|how_to|recommendation|state|architecture|other>] \
  [--promote]

Reports a compact learning signal and optionally promotes it into the local learning plane.
USAGE
  exit 1
}

source_system=""
title=""
summary=""
workspace=""
source_ref=""
severity="medium"
tags=""
root_cause=""
fix=""
solution=""
details=""
affected_services=""
entry_type="problem"
promote="false"

while [ $# -gt 0 ]; do
  case "$1" in
    --source-system) source_system="$2"; shift 2;;
    --title) title="$2"; shift 2;;
    --summary) summary="$2"; shift 2;;
    --workspace) workspace="$2"; shift 2;;
    --source-ref) source_ref="$2"; shift 2;;
    --severity) severity="$2"; shift 2;;
    --tags) tags="$2"; shift 2;;
    --root-cause) root_cause="$2"; shift 2;;
    --fix) fix="$2"; shift 2;;
    --solution) solution="$2"; shift 2;;
    --details) details="$2"; shift 2;;
    --affected-services) affected_services="$2"; shift 2;;
    --entry-type) entry_type="$2"; shift 2;;
    --promote) promote="true"; shift 1;;
    *) usage;;
  esac
done

[ -n "$source_system" ] || usage
[ -n "$title" ] || usage
[ -n "$summary" ] || usage

if [ -z "$workspace" ]; then
  workspace="vizion-infra"
fi

if [ -z "$source_ref" ]; then
  source_ref="${source_system}:$(printf '%s' "${title}|${summary}" | sha256sum | cut -c1-10)"
fi

if [ -z "$fix" ] && [ -n "$solution" ]; then
  fix="$solution"
fi

if [ -z "$details" ] && [ -n "$fix" ]; then
  details="$fix"
fi

if [ "$promote" = "false" ] && { [ -n "$fix" ] || [ -n "$solution" ]; }; then
  promote="true"
fi

fingerprint="$(printf '%s' "${source_system}|${workspace}|${source_ref}|${title}|${summary}" | sha256sum | cut -c1-16)"

payload_json="$(
  SOURCE_SYSTEM="$source_system" \
  SOURCE_REF="$source_ref" \
  ROOT_CAUSE="$root_cause" \
  FIX="$fix" \
  SOLUTION="$solution" \
  DETAILS="$details" \
  AFFECTED_SERVICES="$affected_services" \
  python3 - <<'PY'
import json, os

def compact(value, limit=None):
    text = "" if value is None else str(value).strip()
    if limit is not None and len(text) > limit:
        return text[:limit].rstrip() + "…"
    return text

services = [s.strip() for s in os.environ.get("AFFECTED_SERVICES", "").split(",") if s.strip()]

payload = {
    "source_system": compact(os.environ.get("SOURCE_SYSTEM")),
    "source_ref": compact(os.environ.get("SOURCE_REF")),
    "root_cause": compact(os.environ.get("ROOT_CAUSE"), 500),
    "fix": compact(os.environ.get("FIX"), 500),
    "solution": compact(os.environ.get("SOLUTION"), 500),
    "details": compact(os.environ.get("DETAILS"), 1000),
    "affected_services": services,
}

print(json.dumps({k: v for k, v in payload.items() if v}))
PY
)"

args=(
  --fingerprint "$fingerprint"
  --source-system "$source_system"
  --title "$title"
  --summary "$summary"
  --workspace "$workspace"
  --source-ref "$source_ref"
  --severity "$severity"
  --payload "$payload_json"
  --tags "$tags"
  --entry-type "$entry_type"
)

if [ "$promote" = "true" ]; then
  args+=(--promote)
fi

/root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_ingest.sh "${args[@]}"
