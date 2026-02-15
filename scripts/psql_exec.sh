#!/usr/bin/env bash
set -euo pipefail

# Executes SQL against AIDB in the postgres container.
# Usage: ./scripts/psql_exec.sh < sql/file.sql

CONTAINER=${PG_CONTAINER:-postgresql-pv9y-postgresql-1}
DB=${PGDATABASE:-AIDB}
USER=${PGUSER:-VizionAI}

exec docker exec -i "$CONTAINER" psql -v ON_ERROR_STOP=1 -U "$USER" -d "$DB" "$@"
