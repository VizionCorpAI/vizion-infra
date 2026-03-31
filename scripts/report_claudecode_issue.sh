#!/usr/bin/env bash
set -euo pipefail

exec /root/VizionAI/WORKSPACES/vizion-infra/scripts/report_learning_issue.sh --source-system claudecode "$@"
