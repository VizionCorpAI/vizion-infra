# Airtable Library Mirror

This directory is a generated mirror of the learning plane for queryability.
The local `vizion-infra/learning/` tree remains canonical for detailed docs,
runbooks, architecture notes, and source material.

## What goes here
- Compact summaries
- Tags and statuses
- Source links and references
- Small curated rows for services, problems, articles, recommendations, signals, and prompts
- Trading learning interface docs and compact pattern notes
- Web captures that were normalized with `crawl4ai` before promotion
- Trading Airtable automation instructions live in `vizion-analytics/docs/runbooks/airtable_trading_automation.md`

## What stays local
- Full runbooks and detailed documentation
- Raw logs and long payloads
- Secrets or credentials
- Anything that should remain in Infisical or the local learning plane

## Mirror Rules
- Do not hand-edit the CSV files.
- Treat `learning_ingest.sh` and `learning_promote.sh` as the writers.
- Keep signal rows trimmed so stale inbox items do not accumulate forever.
