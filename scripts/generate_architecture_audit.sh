#!/usr/bin/env bash
set -euo pipefail

# Generate an architecture audit report (HTML + DOCX) for the whole VizionAI VPS.
# Output is stored under vizion-infra/wiki/audit/<YYYY-MM-DD>_audit.html.
#
# Notes:
# - Intentionally avoids printing secrets/environment dumps.
# - Uses LibreOffice (soffice) for HTML -> DOCX conversion, with a timeout.

ROOT="/root/VizionAI"
WORKSPACES="$ROOT/WORKSPACES"
INFRA="$WORKSPACES/vizion-infra"
PLATFORM="$WORKSPACES/vizion-platform"

today_utc="$(date -u +%F)"
out_dir="$INFRA/wiki/audit"
mkdir -p "$out_dir"

html="$out_dir/${today_utc}_audit.html"
docx="$out_dir/${today_utc}_audit.docx"

cmd_or_true() {
  # Run command, capture output, never fail the whole report.
  (bash -lc "$*" 2>&1 || true)
}

esc_html() {
  # Basic HTML escaping for pre blocks.
  sed -e 's/&/&amp;/g' -e 's/</&lt;/g' -e 's/>/&gt;/g'
}

timers="$(cmd_or_true "systemctl list-timers --all --no-pager | rg -n 'vizion-|n8n|openclaw|vaultwarden|monarx' || true")"
services="$(cmd_or_true "systemctl list-units --type=service --all --no-pager | rg -n 'vizion-|n8n|openclaw|vaultwarden|monarx|xrdp' || true")"
docker_ps="$(cmd_or_true "timeout 5s docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}' || true")"
ports="$(cmd_or_true "timeout 5s ss -ltnp | rg -n '(:48950|:32769|:32768|:32770|:8000|:5432|:3276[0-9])' || true")"

ws_overview="$(cmd_or_true "cd \"$WORKSPACES\" && ls -1 | rg -n '^vizion-' || true")"

# Build git summary without relying on nested shell quoting.
ws_git="$(
  cd "$WORKSPACES"
  for ws in vizion-*; do
    [ -d "$ws/.git" ] || continue
    echo "== $ws =="
    echo "remote=$(timeout 5s git -C "$ws" remote get-url origin 2>/dev/null || true)"
    echo "branch=$(timeout 5s git -C "$ws" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
    echo "dirty=$(timeout 5s git -C "$ws" status --porcelain=v1 2>/dev/null | wc -l)"
    echo
  done
)"

registry_csv="$(cmd_or_true "sed -n '1,200p' \"$PLATFORM/registry/workspaces.csv\" 2>/dev/null || true")"
deps_csv="$(cmd_or_true "sed -n '1,250p' \"$PLATFORM/registry/workspace_dependencies.csv\" 2>/dev/null || true")"
legacy_registry_sql="$(cmd_or_true "sed -n '1,260p' \"$INFRA/sql/legacy/001_workspace_repo_registry.sql\" 2>/dev/null || true")"

nn_health="$(cmd_or_true "curl -s --max-time 5 http://127.0.0.1:8000/health || true")"
openclaw_head="$(cmd_or_true "curl -s -I --max-time 5 http://127.0.0.1:48950/ | head -n 5 || true")"
n8n_head="$(cmd_or_true "curl -s -I --max-time 5 http://127.0.0.1:32769/ | head -n 5 || true")"
vw_head="$(cmd_or_true "curl -s -I --max-time 5 http://127.0.0.1:32768/ | head -n 8 || true")"

openclaw_skills_ls="$(cmd_or_true "ls -la /docker/openclaw-xbkt/data/skills 2>/dev/null | head -n 200 || true")"

mermaid_diagram="$(cat <<'MERMAID'
flowchart LR
  subgraph VPS[Hostinger VPS]
    SCHED[Central Scheduler\n(vizion-scheduling-runner.timer)] --> DB[(Postgres AIDB)]
    SCHED --> JOBS[sched_job / sched_job_run]
    SCHED --> PLATFORM[vizion-platform\n(plan_from_alerts + dispatch_tasks)]
    PLATFORM --> TASKS[platform_task]
    PLATFORM --> ALERTS[alert_event]
    ALERTS --> FANOUT[vizion-alert-reporting\nfanout_run]
    FANOUT --> N8N[n8n]
    FANOUT --> OC[OpenClaw]
    TRD[vizion-trading] --> ALERTS
    MKT[vizion-marketing] --> ALERTS
    MAINT[vizion-maintenance] --> ALERTS
    ANA[vizion-analytics] --> ALERTS
    NN[vizion-nn.service\n:8000] --> TRD
    VW[Vaultwarden\n:32768] --- UI[(RDP/Xorg Browser)]
  end
MERMAID
)"

cat >"$html" <<HTML
<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <title>VizionAI Architecture Audit ($today_utc)</title>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.35; margin: 28px; color: #111; }
    h1,h2,h3 { margin: 0.6em 0 0.2em; }
    .meta { color: #444; font-size: 0.95em; margin-bottom: 16px; }
    .box { border: 1px solid #ddd; padding: 12px 14px; border-radius: 8px; margin: 10px 0 18px; }
    pre { background: #0b1020; color: #e8eefc; padding: 12px; border-radius: 8px; overflow: auto; font-size: 12px; }
    code { background: #f2f2f2; padding: 2px 4px; border-radius: 4px; }
    .warn { background: #fff7ed; border: 1px solid #fed7aa; }
    .ok { background: #f0fdf4; border: 1px solid #bbf7d0; }
    ul { margin-top: 6px; }
  </style>
</head>
<body>
  <h1>VizionAI Architecture Audit</h1>
  <div class="meta">
    Date (UTC): <b>$today_utc</b><br/>
    Host: <code>$(hostname)</code><br/>
    Scope: Workspaces, orchestration, containers, ports, and registry alignment.
  </div>

  <h2>High-Level Diagram (Mermaid)</h2>
  <div class="box">
    <p>This is a text diagram you can paste into a Mermaid renderer:</p>
    <pre>$(printf "%s" "$mermaid_diagram" | esc_html)</pre>
  </div>

  <h2>Orchestration</h2>
  <div class="box ok">
    <ul>
      <li>Single orchestrator timer expected: <code>vizion-scheduling-runner.timer</code></li>
      <li>Scheduler writes jobs to <code>sched_job</code> and executes allowlisted job types</li>
    </ul>
  </div>

  <h3>Systemd Timers</h3>
  <pre>$(printf "%s" "$timers" | esc_html)</pre>

  <h3>Systemd Services</h3>
  <pre>$(printf "%s" "$services" | esc_html)</pre>

  <h2>Runtime Services (Docker)</h2>
  <pre>$(printf "%s" "$docker_ps" | esc_html)</pre>

  <h2>Listening Ports</h2>
  <pre>$(printf "%s" "$ports" | esc_html)</pre>

  <h2>Health Checks</h2>
  <div class="box">
    <ul>
      <li>NN: <code>http://127.0.0.1:8000/health</code></li>
      <li>OpenClaw: <code>http://127.0.0.1:48950/</code></li>
      <li>n8n: <code>http://127.0.0.1:32769/</code></li>
      <li>Vaultwarden: <code>http://127.0.0.1:32768/</code></li>
    </ul>
  </div>
  <h3>NN Health JSON</h3>
  <pre>$(printf "%s" "$nn_health" | esc_html)</pre>
  <h3>HTTP HEAD (OpenClaw / n8n / Vaultwarden)</h3>
  <pre>$(printf "%s\n%s\n%s" "$openclaw_head" "$n8n_head" "$vw_head" | esc_html)</pre>

  <h2>Workspaces</h2>
  <h3>Workspace Directories</h3>
  <pre>$(printf "%s" "$ws_overview" | esc_html)</pre>

  <h3>Workspace Git State</h3>
  <pre>$(printf "%s" "$ws_git" | esc_html)</pre>

  <h2>Registry Alignment</h2>
  <div class="box warn">
    <p><b>Potential drift:</b> the legacy registry SQL under <code>WORKSPACES/vizion-infra/sql/legacy/001_workspace_repo_registry.sql</code> may still describe historical paths/remotes. Confirm the platform registry (<code>WORKSPACES/vizion-platform/registry</code>) is considered the source of truth before editing.</p>
  </div>

  <h3>Platform Registry (workspaces.csv)</h3>
  <pre>$(printf "%s" "$registry_csv" | esc_html)</pre>

  <h3>Workspace Dependencies (workspace_dependencies.csv)</h3>
  <pre>$(printf "%s" "$deps_csv" | esc_html)</pre>

  <h3>Legacy Registry SQL (for cleanup/redirect)</h3>
  <pre>$(printf "%s" "$legacy_registry_sql" | esc_html)</pre>

  <h2>OpenClaw Skills Sync</h2>
  <div class="box">
    <p>OpenClaw skill directory on host: <code>/docker/openclaw-xbkt/data/skills</code></p>
  </div>
  <pre>$(printf "%s" "$openclaw_skills_ls" | esc_html)</pre>

  <h2>Findings / Recommendations</h2>
  <div class="box">
    <ul>
      <li>Keep scheduler as the only recurring systemd timer; ensure per-workspace timers remain disabled.</li>
      <li>Resolve git DNS failures if they recur (observed previously as transient).</li>
      <li>Converge legacy infra SQL registry to the platform registry or remove it to avoid confusion.</li>
      <li>Vaultwarden: configure <code>ADMIN_TOKEN</code> using an Argon2 PHC hash (Vaultwarden logs warn about plaintext token).</li>
    </ul>
  </div>
</body>
</html>
HTML

rm -f "$docx"

if [ "${SKIP_DOCX:-}" = "1" ]; then
  echo "SKIP_DOCX=1; generated HTML only: $html" >&2
  exit 0
fi

if ! command -v soffice >/dev/null 2>&1; then
  echo "soffice not found; generated HTML only: $html" >&2
  exit 0
fi

soffice_cmd=(soffice --headless --nologo --nolockcheck --nodefault --norestore
  --convert-to docx --outdir "$out_dir" "$html")

if command -v timeout >/dev/null 2>&1; then
  timeout 60s "${soffice_cmd[@]}" >/dev/null 2>&1 || true
else
  "${soffice_cmd[@]}" >/dev/null 2>&1 || true
fi

if [ ! -f "$docx" ]; then
  # LibreOffice names output after input file base name.
  maybe="$out_dir/$(basename "$html" .html).docx"
  if [ -f "$maybe" ]; then
    mv -f "$maybe" "$docx"
  fi
fi

echo "wrote: $html"
if [ -f "$docx" ]; then
  echo "wrote: $docx"
else
  echo "docx conversion failed; HTML is available at: $html" >&2
fi
