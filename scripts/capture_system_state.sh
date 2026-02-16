#!/usr/bin/env bash
set -euo pipefail

# Capture system state into vizion-infra audit artifacts.
# - Generates HTML/DOCX architecture audit under wiki/audit/
# - Captures deep audit snapshots under audit/

ROOT="/root/VizionAI"
WORKSPACES="$ROOT/WORKSPACES"
INFRA="$WORKSPACES/vizion-infra"
AUDIT_DIR="$INFRA/audit"
DATE_UTC="$(date -u +%F)"

mkdir -p "$AUDIT_DIR"

cmd_or_true() {
  (bash -lc "$*" 2>&1 || true)
}

echo "capture_system_state: generating architecture audit..."
SKIP_DOCX=1 "$INFRA/scripts/generate_architecture_audit.sh" 2>&1 || true

echo "capture_system_state: capturing host inventory..."
cmd_or_true "uname -a" > "$AUDIT_DIR/uname_${DATE_UTC}.txt"
cmd_or_true "cat /etc/os-release" > "$AUDIT_DIR/os_release_${DATE_UTC}.txt"
cmd_or_true "df -h" > "$AUDIT_DIR/df_${DATE_UTC}.txt"
cmd_or_true "free -h" > "$AUDIT_DIR/memory_${DATE_UTC}.txt"

echo "capture_system_state: capturing services/timers/ports..."
cmd_or_true "systemctl list-units --type=service --state=running --no-pager" > "$AUDIT_DIR/systemd_services_${DATE_UTC}.txt"
cmd_or_true "systemctl list-timers --all --no-pager" > "$AUDIT_DIR/systemd_timers_${DATE_UTC}.txt"
cmd_or_true "ss -lntp" > "$AUDIT_DIR/ports_${DATE_UTC}.txt"

echo "capture_system_state: capturing docker overview..."
cmd_or_true "timeout 5s docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}' || true" > "$AUDIT_DIR/docker_ps_${DATE_UTC}.txt"

echo "capture_system_state: capturing logs..."
cmd_or_true "journalctl -u vizion-nn.service -n 200 --no-pager" > "$AUDIT_DIR/journal_vizion-nn_${DATE_UTC}.log"
cmd_or_true "journalctl -u vizion-scheduling-runner.service -n 200 --no-pager" > "$AUDIT_DIR/journal_vizion-scheduling-runner_${DATE_UTC}.log"
cmd_or_true "journalctl -u docker.service -n 200 --no-pager" > "$AUDIT_DIR/journal_docker_${DATE_UTC}.log"

echo "capture_system_state: capturing package inventory..."
( dpkg-query -W -f='${Package}\t${Version}\n' || true ) > "$AUDIT_DIR/packages_${DATE_UTC}.txt"

echo "capture_system_state: done"
