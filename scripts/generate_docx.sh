#!/usr/bin/env bash
set -euo pipefail

# Generate DOCX from the latest audit HTML in wiki/audit/.

INFRA="/root/VizionAI/WORKSPACES/vizion-infra"
AUDIT_DIR="$INFRA/wiki/audit"

latest_html="$(ls -1t "$AUDIT_DIR"/*_audit.html 2>/dev/null | head -n 1 || true)"
if [ -z "$latest_html" ]; then
  echo "no audit HTML found under $AUDIT_DIR" >&2
  exit 1
fi

if ! command -v soffice >/dev/null 2>&1; then
  echo "soffice not found; cannot convert to docx" >&2
  exit 1
fi

out_dir="$AUDIT_DIR"
docx="$out_dir/$(basename "$latest_html" .html).docx"
rm -f "$docx"

soffice_cmd=(soffice --headless --nologo --nolockcheck --nodefault --norestore
  --convert-to docx --outdir "$out_dir" "$latest_html")

if command -v timeout >/dev/null 2>&1; then
  timeout 60s "${soffice_cmd[@]}" >/dev/null 2>&1 || true
else
  "${soffice_cmd[@]}" >/dev/null 2>&1 || true
fi

if [ ! -f "$docx" ]; then
  echo "docx conversion failed; HTML is available at: $latest_html" >&2
  exit 2
fi

echo "wrote: $docx"
