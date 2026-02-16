-- Learning plane table: canonical, queryable index of knowledge entries
CREATE TABLE IF NOT EXISTS learning_entry (
  id BIGSERIAL PRIMARY KEY,
  entry_type TEXT NOT NULL, -- problem | how_to | recommendation | state | architecture | other
  title TEXT NOT NULL,
  summary TEXT,
  details TEXT,
  workspace_key TEXT,
  source_system TEXT, -- alert_reporting | maintenance | analytics | security | platform | other
  source_ref TEXT, -- alert_id, task_id, audit_id, etc
  severity TEXT, -- low | medium | high | critical
  tags TEXT[],
  recommendation_action TEXT,
  owner_workspace TEXT,
  status TEXT DEFAULT 'open', -- open | in_progress | completed | superseded
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_learning_entry_type ON learning_entry (entry_type);
CREATE INDEX IF NOT EXISTS idx_learning_entry_workspace ON learning_entry (workspace_key);
CREATE INDEX IF NOT EXISTS idx_learning_entry_status ON learning_entry (status);
CREATE INDEX IF NOT EXISTS idx_learning_entry_tags ON learning_entry USING GIN (tags);
CREATE INDEX IF NOT EXISTS idx_learning_entry_metadata ON learning_entry USING GIN (metadata);
