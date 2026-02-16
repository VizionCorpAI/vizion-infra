# Learning University

This is the human-friendly entrypoint to the learning plane.
Use it as the front door for operators, agents, and analysts.

## What lives here
- Pointers to the most important learning assets
- Summaries for fast situational awareness
- Links to frequent problems, how-tos, and recommendations

## Start Here
- frequent problems: ../frequent_problems/
- how-to guides: ../how_to/
- recommendations: ../recommendations/
- architecture notes: ../architecture/
- state snapshots: ../state/
- ingestion rules: ../ingest/

## Operating Model
- signals arrive from alerts, maintenance, analytics, and security
- curated entries become actionable recommendations
- outcomes are measured and written back into learning
- summaries are refreshed and used by platform during task dispatch

## Automation
- learning promotion: /root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_promote.sh
- summary refresh: /root/VizionAI/WORKSPACES/vizion-infra/scripts/learning_refresh_all_summaries.sh
