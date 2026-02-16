#!/usr/bin/env bash
set -euo pipefail

# Sync local wiki/ to GitHub Wiki repo.
# Prerequisites: Initialize wiki via GitHub web UI first:
#   https://github.com/VizionCorpAI/vizion-infra/wiki/_new
# Usage: ./scripts/wiki_sync.sh

cd "$(dirname "$0")/.."

WIKI_REPO="git@github.com:VizionCorpAI/vizion-infra.wiki.git"
WIKI_CLONE="state/wiki-clone"
WIKI_SOURCE="wiki"

echo "=== Wiki Sync $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="

# Clone or pull wiki repo
if [ -d "$WIKI_CLONE/.git" ]; then
  echo "Pulling latest wiki..."
  git -C "$WIKI_CLONE" pull --rebase || {
    echo "ERROR: Wiki pull failed. Manual merge may be needed." >&2
    exit 1
  }
else
  echo "Cloning wiki repo..."
  git clone "$WIKI_REPO" "$WIKI_CLONE" 2>&1 || {
    echo "ERROR: Wiki repo not found. Initialize via GitHub web UI first:" >&2
    echo "  https://github.com/VizionCorpAI/vizion-infra/wiki/_new" >&2
    exit 1
  }
fi

# Copy wiki content (flatten for GitHub Wiki format)
# GitHub Wiki uses flat structure: Page-Name.md (no subdirs)
# Convert our dir structure: wiki/architecture/00_system_overview.md -> Architecture-00-System-Overview.md

# Copy index as Home
cp "$WIKI_SOURCE/index.md" "$WIKI_CLONE/Home.md"

# Copy architecture pages
for f in "$WIKI_SOURCE/architecture/"*.md; do
  [ -f "$f" ] || continue
  fname=$(basename "$f" .md)
  # Convert to wiki-friendly name
  wiki_name="Architecture-$(echo "$fname" | sed 's/_/-/g')"
  cp "$f" "$WIKI_CLONE/${wiki_name}.md"
done

# Copy audit pages
for f in "$WIKI_SOURCE/audit/"*.md; do
  [ -f "$f" ] || continue
  fname=$(basename "$f" .md)
  wiki_name="Audit-$(echo "$fname" | sed 's/_/-/g')"
  cp "$f" "$WIKI_CLONE/${wiki_name}.md"
done

# Copy ADR pages
for f in "$WIKI_SOURCE/adr/"*.md; do
  [ -f "$f" ] || continue
  fname=$(basename "$f" .md)
  wiki_name="ADR-$(echo "$fname" | sed 's/_/-/g')"
  cp "$f" "$WIKI_CLONE/${wiki_name}.md"
done

# Commit and push
cd "$WIKI_CLONE"
git add -A
if git diff --cached --quiet; then
  echo "No wiki changes to push."
else
  git commit -m "Wiki sync $(date -u +%Y-%m-%d)" --no-verify
  git push origin master 2>&1 || git push origin main 2>&1 || {
    echo "ERROR: Wiki push failed." >&2
    exit 1
  }
  echo "Wiki synced successfully."
fi
