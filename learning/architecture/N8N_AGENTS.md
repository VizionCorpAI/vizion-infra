---
summary: "VizionAI n8n Agent Capability Registry — semantic lookup for all 39 active agents"
updated: "2026-03-03"
---

# N8N Agent Capability Registry

Complete semantic reference for all active n8n AI agents. Use this file to match any user
request to the correct agent and call it directly via webhook.

**Base URL (from OpenClaw container):** `http://172.19.0.1:32769`
**Webhook pattern:** `POST {base}/webhook/{ID}/webhook/{PATH}`
**Standard payload:** `{"chatInput": "<instruction>", "sessionId": "openclaw-main"}`
**Standard response:** `{"response": "...", "model": "...", "tier": 0, "workspace": "...", "agent": "..."}`

---

## MAINTENANCE

### Cleanup Optimizer
**Does:** Frees disk space — removes stale Docker image layers, old log files, temp files, orphaned volumes, cache
**Call when:** storage full, disk space low, free space, cleanup, optimize storage, prune docker, remove old files, disk usage high, running out of space
**URL:** `POST http://172.19.0.1:32769/webhook/QuhckXw5IqnbRfLg/webhook/chat/cleanup-optimizer`

### Auto Repair
**Does:** Detects and fixes common runtime issues — restarts failed containers, repairs broken services, resolves configuration drift
**Call when:** something is broken, container crashed, service down, auto-fix, repair, restore service, fix issue
**URL:** `POST http://172.19.0.1:32769/webhook/hfwj3tEnsyv037JH/webhook/chat/auto-repair`

### Backup Manager
**Does:** Runs backups of data, configs, and workspace files; manages backup schedules and retention
**Call when:** backup, save state, archive, snapshot data, create backup, backup database, preserve data
**URL:** `POST http://172.19.0.1:32769/webhook/aJQfil251QPIT1cp/webhook/chat/backup-manager`

### Health Checker
**Does:** Comprehensive health check of all services — n8n, MT5, NN server, PostgreSQL, containers; returns detailed status report
**Call when:** health check, system status, everything ok, check all services, are things running, system health, full status check
**URL:** `POST http://172.19.0.1:32769/webhook/xlDt5ByTULvB1edF/webhook/chat/health-checker`

### Resource Monitor
**Does:** Monitors CPU, memory, disk, and network usage across containers; alerts on threshold breaches
**Call when:** resource usage, CPU high, memory usage, disk stats, container resources, system load, performance check
**URL:** `POST http://172.19.0.1:32769/webhook/4SmbwXrZjUykhNri/webhook/chat/resource-monitor`

---

## INFRASTRUCTURE

### Container Manager
**Does:** Manages Docker containers — restart, stop, start, inspect logs, update images, scale services
**Call when:** restart container, stop container, docker, container logs, update image, scale, manage containers
**URL:** `POST http://172.19.0.1:32769/webhook/bg0kMJFELtShSAU4/webhook/chat/container-manager`

### Deployment Helper
**Does:** Assists with deployments — rolling updates, version pinning, rollback, deployment status
**Call when:** deploy, deployment, update service, rollback, release, push update, version update
**URL:** `POST http://172.19.0.1:32769/webhook/4KyLCtdE5f1sk2NF/webhook/chat/deployment-helper`

### Network Diagnostics
**Does:** Diagnoses network issues — connectivity checks, DNS lookups, port probes, latency tests, route tracing
**Call when:** network issue, can't connect, connectivity problem, ping, port check, DNS issue, firewall, network test
**URL:** `POST http://172.19.0.1:32769/webhook/lj5OAvcuC97D0yWt/webhook/chat/network-diagnostics`

### Workflow Deployer
**Does:** Deploys new or updated n8n workflows — imports JSON, activates, validates webhooks
**Call when:** deploy workflow, import n8n workflow, activate workflow, update workflow, push workflow to n8n
**URL:** `POST http://172.19.0.1:32769/webhook/Xc9PUYwnEzyWUoxJ/webhook/chat/workflow-deployer`

---

## SECURITY

### Threat Scanner
**Does:** Scans for security threats — suspicious processes, open ports, failed login attempts, anomalous behavior, CVEs
**Call when:** security scan, threat check, scan for threats, security audit, check for vulnerabilities, intrusion detection, suspicious activity
**URL:** `POST http://172.19.0.1:32769/webhook/q4XaqZAVE1yF2ABS/webhook/chat/threat-scanner`

### Audit Logger
**Does:** Records and queries security audit events; produces audit trails; searches event history
**Call when:** audit log, security events, who did what, access log, event history, audit trail, compliance log
**URL:** `POST http://172.19.0.1:32769/webhook/ATxAXqOoGvsEz6wf/webhook/chat/audit-logger`

### Compliance Checker
**Does:** Checks system configuration against security policies — secret exposure, permission drift, policy violations
**Call when:** compliance check, policy check, is this compliant, security policy, permission audit, check configuration
**URL:** `POST http://172.19.0.1:32769/webhook/VL46aM1DafKgV3C6/webhook/chat/compliance-checker`

### Secret Rotator
**Does:** Rotates API keys, tokens, and credentials; updates Infisical; notifies affected services
**Call when:** rotate secrets, rotate API key, update credentials, refresh token, secret rotation, change password, expire key
**URL:** `POST http://172.19.0.1:32769/webhook/YPwZ2B1ELjfm9RQh/webhook/chat/secret-rotator`

---

## TRADING

### Market Analyzer
**Does:** AI-powered market analysis for XAUUSD, US30, NAS100 — bias scoring (MFIB/MA stack/Stoch), trade setup identification, confluence analysis
**Call when:** market analysis, analyze gold, analyze XAUUSD, market bias, what's the market doing, trade setup, technical analysis, market outlook
**URL:** `POST http://172.19.0.1:32769/webhook/GDdumjIotZrXrC6P/webhook/chat/market-analyzer`

### Risk Checker
**Does:** Evaluates trade risk — position sizing, exposure limits, drawdown checks, max lot validation
**Call when:** check risk, risk assessment, is this trade safe, position size, max risk, drawdown, lot size check
**URL:** `POST http://172.19.0.1:32769/webhook/KWTLgiQmsrBNxuDh/webhook/chat/risk-checker`

### Trading Executor
**Does:** Executes trades on MT5 (demo or live) via the trade trigger webhook; requires user confirmation
**Call when:** place trade, execute trade, buy XAUUSD, sell gold, open position, enter trade — ALWAYS CONFIRM BEFORE CALLING
**URL:** `POST http://172.19.0.1:32769/webhook/CW1CSd3sieBQSo2I/webhook/chat/trading-executor`

### Strategy Backtester
**Does:** Backtests trading strategies against historical data using vizion-nn and indicator snapshots
**Call when:** backtest, test strategy, historical performance, how would this have done, backtest results
**URL:** `POST http://172.19.0.1:32769/webhook/o86lOMFGbwK4yS0i/webhook/chat/strategy-backtester`

### Trend Detector
**Does:** Identifies market trends — HH/HL/LH/LL structure, BOS/CHoCH, multi-timeframe trend alignment
**Call when:** trend analysis, what's the trend, market structure, BOS, CHoCH, higher highs, trend direction
**URL:** `POST http://172.19.0.1:32769/webhook/y0og7kVmXiN4IDgs/webhook/chat/trend-detector`

### News Monitor
**Does:** Monitors financial news and economic events; filters for high-impact catalysts affecting watched symbols
**Call when:** news, economic events, high impact news, fed news, CPI, NFP, what's in the news, news catalyst
**URL:** `POST http://172.19.0.1:32769/webhook/FJQUqGpMZPWCcDVp/webhook/chat/news-monitor`

---

## ANALYTICS

### Data Analyst
**Does:** Queries and analyzes data from PostgreSQL AIDB — trades, signals, platform metrics, custom queries
**Call when:** data analysis, query database, analyze data, show me data, stats, metrics, database query, how many, chart data
**URL:** `POST http://172.19.0.1:32769/webhook/8UyesOTnQZqqBmlE/webhook/chat/data-analyst`

### Report Generator
**Does:** Generates structured reports — trading performance, system health, cost summaries, workspace activity
**Call when:** generate report, create report, performance report, summary report, weekly report, monthly report
**URL:** `POST http://172.19.0.1:32769/webhook/3fiNEA0P88uYCFbH/webhook/chat/report-generator`

### Analytics Aggregator
**Does:** Aggregates analytics data across workspaces — social metrics, trading stats, platform-wide KPIs
**Call when:** aggregate analytics, combined stats, platform metrics, aggregate data, rollup report, KPIs
**URL:** `POST http://172.19.0.1:32769/webhook/fVtjp51rXuqftzD3/webhook/chat/analytics-aggregator`

---

## PLATFORM

### Workspace Router
**Does:** Routes any request to the correct specialist workspace/agent using AI reasoning — USE AS FALLBACK when unsure
**Call when:** FALLBACK — any request you can't route confidently
**URL:** `POST http://172.19.0.1:32769/webhook/zLdNy1r4gFPrHnZp/webhook/chat/workspace-router`

### Task Dispatcher
**Does:** Dispatches platform tasks to target workspaces; inserts into task queue; tracks completion
**Call when:** dispatch task, send task to workspace, platform task, schedule a task for the team
**URL:** `POST http://172.19.0.1:32769/webhook/Hzi7lEUTL4SlgvHD/webhook/chat/task-dispatcher`

### Cross Workspace Sync
**Does:** Synchronizes state and data across workspaces — memory sync, config replication, registry updates
**Call when:** sync workspaces, cross-workspace sync, replicate config, sync state, workspace sync
**URL:** `POST http://172.19.0.1:32769/webhook/Ipc0wNNHNO1d9wKh/webhook/chat/cross-workspace-sync`

---

## ONBOARDING

### Client Setup
**Does:** Sets up new clients — creates workspace scaffold, registers channels, imports credentials
**Call when:** onboard client, new client, setup client, register client, create client workspace
**URL:** `POST http://172.19.0.1:32769/webhook/BWLqZGH9pB24h2Xy/webhook/chat/client-setup`

### Channel Configurator
**Does:** Configures communication channels (WhatsApp, Telegram, Slack, Discord) for clients
**Call when:** configure channel, setup WhatsApp, add Telegram, configure Discord, channel setup
**URL:** `POST http://172.19.0.1:32769/webhook/QTWax1Oz5si4epky/webhook/chat/channel-configurator`

### Validation Tester
**Does:** Runs post-setup validation tests — verifies webhooks, tests credentials, confirms connectivity
**Call when:** validate setup, test configuration, run tests, check setup, verify credentials, test webhooks
**URL:** `POST http://172.19.0.1:32769/webhook/QMUoQwsyHpygRoqf/webhook/chat/validation-tester`

### Workflow Deployer
**Does:** Deploys n8n workflows for new workspace setups; activates and registers in registry
**Call when:** deploy workspace workflows, setup workflows for client, import workflow package
**URL:** `POST http://172.19.0.1:32769/webhook/Xc9PUYwnEzyWUoxJ/webhook/chat/workflow-deployer`

---

## MARKETING

### Content Creator
**Does:** Creates social media content — captions, post copy, hashtags, image prompts for Facebook/Instagram
**Call when:** create content, write post, social media post, caption, marketing copy, draft content
**URL:** `POST http://172.19.0.1:32769/webhook/LEXozqGWxNrmx0hV/webhook/chat/content-creator`

### Lead Qualifier
**Does:** Qualifies incoming leads — scores against criteria, determines next action, updates CRM data
**Call when:** qualify lead, lead scoring, is this a good lead, evaluate prospect, lead follow-up
**URL:** `POST http://172.19.0.1:32769/webhook/kbEA33mnJzL2FDqu/webhook/chat/lead-qualifier`

### Social Poster
**Does:** Posts content to social media platforms (Facebook, Instagram, LinkedIn) via configured APIs
**Call when:** post to social, publish post, post on Facebook, share on Instagram, social post
**URL:** `POST http://172.19.0.1:32769/webhook/fYJZsSHZroHlppjt/webhook/chat/social-poster`

### Comment Responder
**Does:** Drafts or sends responses to social media comments; manages comment moderation
**Call when:** respond to comment, reply comment, comment moderation, social comment, reply to DM
**URL:** `POST http://172.19.0.1:32769/webhook/hbaUNgJ5rAYAgflz/webhook/chat/comment-responder`

---

## ALERT & NOTIFICATIONS

### Alert Router
**Does:** Routes incoming system alerts to the correct handler workspace based on alert type and severity
**Call when:** route alert, handle alert, alert triage, process system alert
**URL:** `POST http://172.19.0.1:32769/webhook/mdMi7jaTdGQrdGi1/webhook/chat/alert-router`

### Alert Aggregator
**Does:** Aggregates and deduplicates alerts; produces alert summaries; manages alert fatigue
**Call when:** aggregate alerts, alert summary, what alerts are there, summarize alerts, alert report
**URL:** `POST http://172.19.0.1:32769/webhook/JuwnG2v1TZHZRWgc/webhook/chat/alert-aggregator`

### Notification Sender
**Does:** Sends notifications to configured channels (Telegram, WhatsApp, Discord) on behalf of the platform
**Call when:** send notification, notify user, push notification, send message to channel, alert user
**URL:** `POST http://172.19.0.1:32769/webhook/HQObBnsHLIybTlib/webhook/chat/notification-sender`

---

## SPECIAL / DIRECT ACCESS

### EA AI Gateway
**Does:** Multi-action gateway for MT5 EA integration — validate trades, get briefings, session info, news bias, report trades
**Actions:** `ping`, `validate_trade`, `get_briefing`, `get_session`, `get_news_bias`, `report_trade`, `watchlist_status`
**URL:** `POST http://172.19.0.1:32769/webhook/6VeJRjTNrrxCQK8u/webhook/ea-gateway`
**Payload:** `{"action": "ping"}` or `{"action": "get_briefing", "symbol": "XAUUSD"}`

### Trade Trigger
**Does:** Executes MT5 trades directly — bypasses AI, goes straight to MT5 REST server (REQUIRES explicit user confirmation)
**URL:** `POST http://172.19.0.1:32769/webhook/wf_trade_trigger_001/webhook/trade-trigger`
**Payload:** `{"symbol":"XAUUSD","direction":"buy","volume":0.01,"account":"demo","sl_pips":20,"tp_pips":40}`

### Lead Capture
**Does:** Captures and stores new inbound leads from web forms or manual entry
**URL:** `POST http://172.19.0.1:32769/webhook/6RXsJljW8z6KujCX/webhook/lead-capture`

### Multi-Platform Publisher
**Does:** Publishes the same content to multiple social platforms simultaneously
**URL:** `POST http://172.19.0.1:32769/webhook/3lm99h8Q6MhfFlaZ/webhook/publish-multi-platform`

### Alert Ingest
**Does:** Ingests raw system alerts into the alert pipeline (internal system webhook)
**URL:** `POST http://172.19.0.1:32769/webhook/UHmCR6VzI876gb75/webhook/vizion/alert/ingest`

### Wiki Sync
**Does:** Syncs the vizion-infra wiki to GitHub
**URL:** `POST http://172.19.0.1:32769/webhook/u2cbrqVSJb0rhaci/webhook/vizion/infra/wiki-sync`

---

## OPENCLAW SUB-AGENTS (Native Delegation)

These are full workspace agents — use when a task needs multi-step orchestration, memory, or workspace ownership.
Invoke via OpenClaw's native sub-agent delegation (not via HTTP).

| Sub-agent | Use for |
|-----------|---------|
| `trading` | Deep trading analysis, signal generation, MFIB/MA model, MT5 interaction |
| `analytics` | Data analysis, report generation, trend analysis across workspaces |
| `security` | Threat response, secrets management, compliance investigations, Infisical |
| `platform` | Cross-workspace orchestration, registry management, task dispatch |
| `maintenance` | System maintenance tasks, audit scheduling, disk/container hygiene |
| `infra` | Architecture docs, wiki updates, DocOps cycles, audit snapshots |
| `onboarding` | Full client onboarding flows, workspace scaffolding |
| `marketing` | Social media strategy, content campaigns, lead management |
| `scheduling` | Scheduling cron jobs, time-based tasks, reminder setup |
| `alert-reporting` | Alert pipeline management, notification configuration |

---

## QUICK DECISION GUIDE

```
User asks to DO something
    ├─ Matches a specific agent above? → Call it directly
    ├─ Unclear which agent? → Route via Workspace Router
    └─ Multi-step or needs memory? → Delegate to sub-agent

User asks for INFORMATION
    ├─ Platform status/health? → Health Checker or Data Analyst
    ├─ Market/trading? → Market Analyzer or Trend Detector
    └─ How to do something? → Check University at /workspaces/vizion-infra/learning/
```
