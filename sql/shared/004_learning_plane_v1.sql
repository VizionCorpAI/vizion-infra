-- Learning plane v1: signals, actions, outcomes, summaries, cases, evals, prompts

CREATE TABLE IF NOT EXISTS learn_signal (
  id BIGSERIAL PRIMARY KEY,
  fingerprint TEXT NOT NULL UNIQUE,
  source_system TEXT NOT NULL,
  source_ref TEXT,
  severity TEXT,
  title TEXT,
  summary TEXT,
  payload JSONB DEFAULT '{}'::jsonb,
  first_seen TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_seen TIMESTAMPTZ NOT NULL DEFAULT now(),
  seen_count INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_learn_signal_source ON learn_signal (source_system);
CREATE INDEX IF NOT EXISTS idx_learn_signal_last_seen ON learn_signal (last_seen);
CREATE INDEX IF NOT EXISTS idx_learn_signal_payload ON learn_signal USING GIN (payload);

CREATE TABLE IF NOT EXISTS learn_link (
  id BIGSERIAL PRIMARY KEY,
  entry_id BIGINT REFERENCES learning_entry(id) ON DELETE CASCADE,
  link_type TEXT NOT NULL, -- workspace | task | agent | workflow | policy | other
  link_key TEXT NOT NULL,
  link_meta JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_learn_link_entry ON learn_link (entry_id);
CREATE INDEX IF NOT EXISTS idx_learn_link_key ON learn_link (link_type, link_key);

CREATE TABLE IF NOT EXISTS learn_action (
  id BIGSERIAL PRIMARY KEY,
  action_key TEXT NOT NULL UNIQUE,
  entry_id BIGINT REFERENCES learning_entry(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'queued', -- queued | running | done | failed | rolled_back
  planned_tasks JSONB DEFAULT '[]'::jsonb,
  actual_task_ids JSONB DEFAULT '[]'::jsonb,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_learn_action_entry ON learn_action (entry_id);
CREATE INDEX IF NOT EXISTS idx_learn_action_status ON learn_action (status);

CREATE TABLE IF NOT EXISTS learn_outcome (
  id BIGSERIAL PRIMARY KEY,
  action_id BIGINT REFERENCES learn_action(id) ON DELETE CASCADE,
  metric_name TEXT NOT NULL,
  baseline_value NUMERIC,
  post_value NUMERIC,
  delta NUMERIC,
  confidence NUMERIC,
  window_start TIMESTAMPTZ,
  window_end TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_learn_outcome_action ON learn_outcome (action_id);
CREATE INDEX IF NOT EXISTS idx_learn_outcome_metric ON learn_outcome (metric_name);

CREATE TABLE IF NOT EXISTS learn_summary (
  id BIGSERIAL PRIMARY KEY,
  scope_type TEXT NOT NULL, -- system | workspace | agent
  scope_key TEXT NOT NULL,
  summary_md TEXT NOT NULL,
  source_query TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_learn_summary_scope ON learn_summary (scope_type, scope_key);

CREATE TABLE IF NOT EXISTS learn_case (
  id BIGSERIAL PRIMARY KEY,
  case_type TEXT NOT NULL,
  context JSONB NOT NULL,
  expected JSONB,
  actual JSONB,
  labels TEXT[],
  created_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_learn_case_type ON learn_case (case_type);
CREATE INDEX IF NOT EXISTS idx_learn_case_labels ON learn_case USING GIN (labels);
CREATE INDEX IF NOT EXISTS idx_learn_case_context ON learn_case USING GIN (context);

CREATE TABLE IF NOT EXISTS learn_eval (
  id BIGSERIAL PRIMARY KEY,
  case_id BIGINT REFERENCES learn_case(id) ON DELETE CASCADE,
  evaluator TEXT NOT NULL, -- nn | llm | rule_engine | other
  score NUMERIC,
  rubric JSONB,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_learn_eval_case ON learn_eval (case_id);
CREATE INDEX IF NOT EXISTS idx_learn_eval_evaluator ON learn_eval (evaluator);

CREATE TABLE IF NOT EXISTS learn_prompt_version (
  id BIGSERIAL PRIMARY KEY,
  agent_key TEXT NOT NULL,
  version_hash TEXT NOT NULL,
  content_md TEXT NOT NULL,
  active_from TIMESTAMPTZ NOT NULL DEFAULT now(),
  active_to TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_learn_prompt_version_key ON learn_prompt_version (agent_key, version_hash);
