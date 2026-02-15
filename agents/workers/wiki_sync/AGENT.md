# Worker Agent: wiki_sync

## Purpose
Synchronize the local wiki/ directory to the GitHub Wiki repository for vizion-infra.

## Inputs
- Local wiki/ directory content
- GitHub Wiki remote: VizionCorpAI/vizion-infra.wiki.git

## Outputs
- GitHub Wiki updated with latest local content
- sec_audit_log entry for sync event
- Alert event if sync fails

## Safety
- Always pull before push to avoid overwriting external edits
- If merge conflict, abort and alert user
- Never force-push to wiki repo
- Log every sync to audit trail

## Verification
- `git -C wiki.git log --oneline -1` matches latest local commit
- GitHub Wiki renders correctly (spot-check via API)
