# Workspace Responsibility Matrix

This matrix is the practical boundary guide for the VizionAI workspaces.
It focuses on what each workspace owns today, what it should not absorb, and
where it exchanges data with the rest of the system.

## Platform
| Workspace | Owns | Must Not Own | Inputs | Outputs |
|---|---|---|---|---|
| `vizion-platform` | Shared runtime contracts, registry logic, task orchestration conventions, dispatch rules | Domain workflows, provisioning details, long-running audits | Normalized events, workspace registry, task state | `platform_task`, task dispatch, orchestration metadata |

## Infra
| Workspace | Owns | Must Not Own | Inputs | Outputs |
|---|---|---|---|---|
| `vizion-infra` | Provisioning, deployment plumbing, runtime bootstraps, wiki/artifact sync, host/service configuration | Business workflows, analytics, alerting policy, secret contents | Registry data, Docker/systemd state, Git status, runtime env from Infisical | Deployed services, wiki artifacts, docops/audit outputs |

## Security
| Workspace | Owns | Must Not Own | Inputs | Outputs |
|---|---|---|---|---|
| `vizion-security` | Secret policy, RBAC, compliance policy, ecosystem guardrails, audit policy, identity standards, retention rules | General app workflows, infrastructure bootstrap, analytics dashboards, domain-specific execution logic | Infisical state, auth events, scan results, policy review requests, control findings | Policy checks, guardrails, audit logs, rotation actions, compliance attestations |

## Maintenance
| Workspace | Owns | Must Not Own | Inputs | Outputs |
|---|---|---|---|---|
| `vizion-maintenance` | Cleanup, audits, health checks, duplicate pruning, secret hygiene, container hygiene | OS/kernel/firewall administration, business logic, alert routing | Workspace state, containers, disk, secrets inventory, audit findings | Cleanup actions, audit reports, hygiene tasks |

## Scheduling
| Workspace | Owns | Must Not Own | Inputs | Outputs |
|---|---|---|---|---|
| `vizion-scheduling` | Recurring jobs, trigger timing, retry windows, schedule policies | Domain logic, report interpretation, incident handling | `platform_task`, `alert_event`, cron/schedule definitions | Due-job execution, recurring triggers, follow-up jobs |

## Alert Reporting
| Workspace | Owns | Must Not Own | Inputs | Outputs |
|---|---|---|---|---|
| `vizion-alert-reporting` | Alert intake, normalization, fanout, operational summaries, failure reporting | KPI analysis, heavy analytics pipelines, provisioning | Webhook payloads, collector snapshots, workflow failures | `alert_event`, `alert_report_artifact`, downstream notifications, learning-library issue reports |

## Analytics
| Workspace | Owns | Must Not Own | Inputs | Outputs |
|---|---|---|---|---|
| `vizion-analytics` | KPI rollups, trends, anomaly detection, historical evaluation | Real-time paging, secret management, deployment plumbing | `alert_event`, task history, execution history, metrics tables | Rollups, dashboards, anomaly signals, eval outputs |

## Marketing
| Workspace | Owns | Must Not Own | Inputs | Outputs |
|---|---|---|---|---|
| `vizion-marketing` | Marketing campaigns, lead flows, content generation/scheduling, CRM sync | Infra provisioning, system-wide alerting, analytics storage | Leads, content topics, CRM state, social metrics | Scheduled content, lead sync, campaign actions |

## Onboarding
| Workspace | Owns | Must Not Own | Inputs | Outputs |
|---|---|---|---|---|
| `vizion-onboarding` | Client/client-space setup, intake, provisioning workflows, preflight checks | Long-term campaign logic, trading logic, core alerting | New-client requests, workspace templates, configuration checks | Onboarding state, setup actions, preflight issue reports |

## Trading
| Workspace | Owns | Must Not Own | Inputs | Outputs |
|---|---|---|---|---|
| `vizion-trading` | Trading strategies, market data workflows, execution support, trade-specific analytics | Marketing automation, generic infra provisioning, non-trading alert policy | Market data, MT5 state, NN features, execution history | Signals, trades, evaluation data, trade ops outputs |

## Shared Rule
- If a workspace needs to report an issue, it should use the shared learning issue reporter and write compact fields to the Airtable library.
- Detailed writeups stay in the local learning plane.
