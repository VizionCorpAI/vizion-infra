# Trading Learning Library Interface

This interface belongs in the VizionAI Library base and is the compact knowledge
portal for trading lessons, patterns, and post-review summaries.

For the full table schema and field definitions, see
[`trading_airtable_schema.md`](/root/VizionAI/WORKSPACES/vizion-analytics/docs/runbooks/trading_airtable_schema.md).

## Purpose
- Store the promoted learning that comes out of CRM analytics staging
- Keep only compact summaries, tags, source links, and pattern notes
- Give NN-related tools a queryable knowledge layer for prior trading lessons
- Avoid raw trade logs or long backtests in Airtable

## Recommended Interface Pages

1. Trading Knowledge Portal
- Source: `Articles`
- Shows trading learning articles, runbooks, and compact how-to notes
- Filters: `workspace`, `category`, `tags`, `status`

2. Setup Playbooks
- Source: `Articles` and `Recommendations`
- Shows the exact setup names and rules that have proven profitable
- Filters: `setup_name`, `symbol`, `timeframe`, `session`, `status`

3. Pair Playbooks
- Source: `Articles` and `Recommendations`
- Shows which symbol/timeframe pairs perform best
- Filters: `symbol`, `timeframe`, `status`, `tags`

4. Session Playbooks
- Source: `Articles` and `Recommendations`
- Shows which sessions are best for which pairs or setups
- Filters: `session`, `symbol`, `status`, `tags`

5. News Playbook Library
- Source: `Articles` and `Recommendations`
- Shows how to trade or block around news events
- Filters: `importance`, `news_state`, `status`, `tags`

6. Pattern Library
- Source: `Articles` and `Recommendations`
- Shows confirmed recurring market or execution patterns
- Filters: `symbol`, `timeframe`, `pattern_key`, `status`

7. Problem Tracker
- Source: `Problems`
- Shows repeat failures from MT5, NN, or trade execution
- Filters: `severity`, `status`, `affected_services`

8. Signal Inbox
- Source: `Signals`
- Shows compact source notes coming from analytics and trading workspaces
- Filters: `source_type`, `workspace`, `severity`, `status`

9. Prompt and Playbook Index
- Source: `Agent Prompts`
- Shows trading prompts, retraining prompts, and review prompts used by agents
- Filters: `agent`, `category`, `status`

## Interface behavior
- `Trading Knowledge Portal`
  - Use this as the main search page for confirmed trading knowledge
  - Prioritize concise summaries, tags, and source links
  - Best for answering “what worked before?”
- `Setup Playbooks`
  - Use this to store the most profitable setups as compact playbooks
  - Show exact conditions, allowed directions, and notes
  - Best for answering “which setup names actually make money?”
- `Pair Playbooks`
  - Use this to store symbol/timeframe pair guidance
  - Show profitability by pair and the setups that work on it
  - Best for answering “which pairs are worth trading?”
- `Session Playbooks`
  - Use this to store session-specific guidance
  - Show the strongest session for each pair or setup
  - Best for answering “when should we trade?”
- `News Playbook Library`
  - Use this to store news rules, block logic, and directional exceptions
  - Show what to do before and after major events
  - Best for answering “what should we do around news?”
- `Pattern Library`
  - Use this as the pattern reference desk for repeatable market behavior
  - Show symbol, timeframe, evidence count, and confidence at a glance
  - Favor stable pattern names over session-level narrative
- `Problem Tracker`
  - Use this for debugging repeated failures and incident-like issues
  - Sort by severity and due date
  - Keep fixes and prevention notes short and actionable
- `Signal Inbox`
  - Use this for short signal notes that may become articles or recommendations
  - Keep the inbox clean and trim stale rows
  - This is a staging view, not a raw-log store
- `Prompt and Playbook Index`
  - Use this to manage prompt versions and agent-specific playbooks
  - Show active/inactive status and prompt version clearly
  - Keep each row tied to a workspace and source reference

## Library Rules
- Keep summaries short and source-linked
- Promote only after a CRM pattern has been observed and reviewed
- Prefer stable descriptions like `win-rate drift on XAUUSD H4` over session dumps
- Use tags for `trading`, `mt5`, `nn`, `execution`, `risk`, `pattern`, `review`

## Query Shape
- NN and operator tools should search the Library for:
  - prior problems
  - accepted trading patterns
  - trading runbooks
  - model prompt guidance
- The Library should answer “what worked before?” not “what happened in every tick?”
