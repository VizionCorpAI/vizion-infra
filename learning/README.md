# Learning Plane

This directory is the shared learning plane for all VizionAI workspaces. It is the primary location for
state snapshots, architecture notes, how-tos, frequent problems, and operational recommendations.
Everything here is designed to be queryable by platform, maintenance, security, and analytics before
any external search.

## Scope
- System state and architecture references
- Verified how-to runbooks
- Frequent problems and proven fixes
- Recommendations derived from analytics, alerts, and maintenance
- Learning entries linked to source events (alerts, audits, or tasks)

## Structure
- frequent_problems/: Real incidents and recurring issues with root cause and fix.
- how_to/: Verified, step-by-step remediation or setup guides.
- recommendations/: Actions suggested by analytics, maintenance, or security.
- architecture/: Current architecture notes and canonical diagrams or references.
- state/: Audit snapshots, inventories, and runtime observations.
- ingest/: Intake records that map alerts or maintenance findings into learning entries.
- university/: Human-friendly front door into the learning plane.

## Ingestion Rules
- Every entry must have a source (alert, audit, maintenance, analytics).
- Avoid storing secrets or personal data. Reference Infisical paths instead.
- Recommendations should be actionable and assigned an owner workspace.

## Automation
- learning ingest: /root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_ingest.sh
- promotion job: /root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_promote.sh
- summaries: /root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_refresh_all_summaries.sh

## Database
The learning plane is backed by database tables defined in:
- sql/shared/003_learning_plane.sql (learning_entry)
- sql/shared/004_learning_plane_v1.sql (signals, actions, outcomes, summaries, cases, evals, prompts)

Use that table to index entries and recommendations for programmatic retrieval.
