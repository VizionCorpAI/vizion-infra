# System Overview

VizionAI is a multi-workspace system with a central control plane and distributed workspaces. The platform is the authoritative registry and coordinator. Scheduling is centralized. Alerting is centralized via the alert-reporting workspace.

## Core Components
- Platform control plane: `vizion-platform`
- Central scheduler: `vizion-scheduling`
- Telemetry and alerts: `vizion-alert-reporting`
- Analytics: `vizion-analytics`
- Maintenance: `vizion-maintenance`
- Domain workspaces: `vizion-trading`, `vizion-marketing`, `vizion-onboarding`

## Diagram
```mermaid
flowchart LR
  subgraph VPS[Hostinger VPS]
    SCHED[Central Scheduler\n(vizion-scheduling-runner.timer)] --> DB[(Postgres AIDB)]
    SCHED --> JOBS[sched_job / sched_job_run]
    SCHED --> PLATFORM[vizion-platform\n(plan_from_alerts + dispatch_tasks)]
    PLATFORM --> TASKS[platform_task]
    PLATFORM --> ALERTS[alert_event]
    ALERTS --> FANOUT[vizion-alert-reporting\nfanout_run]
    FANOUT --> N8N[n8n]
    FANOUT --> OC[OpenClaw]
    TRD[vizion-trading] --> ALERTS
    MKT[vizion-marketing] --> ALERTS
    MAINT[vizion-maintenance] --> ALERTS
    ANA[vizion-analytics] --> ALERTS
    NN[vizion-nn.service\n:8000] --> TRD
    VW[Vaultwarden\n:32768] --- UI[(RDP/Xorg Browser)]
  end
```
