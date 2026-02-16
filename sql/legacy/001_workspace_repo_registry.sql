CREATE TABLE IF NOT EXISTS workspace_repo_registry (
  id BIGSERIAL PRIMARY KEY,
  workspace_key TEXT NOT NULL UNIQUE,
  agent_key TEXT NOT NULL,
  repo_name TEXT NOT NULL,
  repo_path TEXT NOT NULL,
  repo_remote TEXT NOT NULL,
  workflow_namespace TEXT NOT NULL,
  db_name TEXT NOT NULL,
  db_schema TEXT NOT NULL DEFAULT 'public',
  db_table_prefix TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION touch_workspace_repo_registry_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_workspace_repo_registry_updated_at ON workspace_repo_registry;
CREATE TRIGGER trg_workspace_repo_registry_updated_at
BEFORE UPDATE ON workspace_repo_registry
FOR EACH ROW EXECUTE FUNCTION touch_workspace_repo_registry_updated_at();

INSERT INTO workspace_repo_registry (
  workspace_key, agent_key, repo_name, repo_path, repo_remote, workflow_namespace,
  db_name, db_schema, db_table_prefix, status
) VALUES
  ('trading','trading','vizion-trading','/root/VizionAI/WORKSPACES/vizion-trading','git@github.com:VizionCorpAI/vizion-trading.git','trading','AIDB','public','trade_','active'),
  ('scheduling','scheduling','vizion-scheduling','/root/VizionAI/WORKSPACES/vizion-scheduling','git@github.com:sahrxvision/vizion-scheduling.git','scheduling','AIDB','public','sched_','active'),
  ('marketing','marketing','vizion-marketing','/root/VizionAI/WORKSPACES/vizion-marketing','git@github.com:sahrxvision/vizion-marketing.git','marketing','AIDB','public','mkt_','active'),
  ('agent_builder','builder','vizion-onboarding','/root/VizionAI/WORKSPACES/vizion-onboarding','git@github.com:sahrxvision/vizion-onboarding.git','agent_builder','AIDB','public','agent_','active'),
  ('analytics','analytics','vizion-analytics','/root/VizionAI/WORKSPACES/vizion-analytics','git@github.com:sahrxvision/vizion-analytics.git','analytics','AIDB','public','analytics_','active')
ON CONFLICT (workspace_key) DO UPDATE
SET agent_key = EXCLUDED.agent_key,
    repo_name = EXCLUDED.repo_name,
    repo_path = EXCLUDED.repo_path,
    repo_remote = EXCLUDED.repo_remote,
    workflow_namespace = EXCLUDED.workflow_namespace,
    db_name = EXCLUDED.db_name,
    db_schema = EXCLUDED.db_schema,
    db_table_prefix = EXCLUDED.db_table_prefix,
    status = EXCLUDED.status;
