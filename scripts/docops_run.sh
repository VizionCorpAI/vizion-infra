#!/usr/bin/env bash
set -euo pipefail

# Full DocOps cycle:
# 1. Capture system state (audit snapshot)
# 2. Validate workspace structures
# 3. Audit registry consistency
# 4. Regenerate MEMORY.md across all workspaces
# 5. Sync wiki to GitHub Wiki
# Usage: ./scripts/docops_run.sh

cd "$(dirname "$0")/.."

echo "=== DocOps Cycle $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="

# Step 1: Capture audit snapshot
echo "--- Step 1: Capture System State ---"
./scripts/capture_system_state.sh 2>&1 || echo "WARNING: capture_system_state.sh failed"

# Step 2: Validate workspace structures
echo "--- Step 2: Validate Workspace Structures ---"
./scripts/validate_workspace_structure.sh 2>&1 || echo "WARNING: validate_workspace_structure.sh failed"

# Step 3: Audit registry consistency
echo "--- Step 3: Audit Registry Consistency ---"
./scripts/audit_registry_consistency.sh 2>&1 || echo "WARNING: audit_registry_consistency.sh failed"

# Step 4: Regenerate MEMORY.md
echo "--- Step 4: Regenerate MEMORY.md ---"
./scripts/regenerate_memory.sh 2>&1 || echo "WARNING: regenerate_memory.sh failed"

# Step 5: Sync wiki to GitHub
echo "--- Step 5: Sync Wiki to GitHub ---"
./scripts/wiki_sync.sh 2>&1 || echo "WARNING: wiki_sync.sh failed"

# Record completion
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) docops_complete" >> state/docops_runs.log

echo ""
echo "=== DocOps Cycle Complete ==="
