# Frequent problem: github.com DNS for wiki sync

## Symptom
Running `./scripts/wiki_sync.sh` or DocOps fails during the GitHub clone with:
```
ssh: Could not resolve hostname github.com: Temporary failure in name resolution
fatal: Could not read from remote repository.
```
The DocOps log is `state/docops_runs.log` and the wiki sync report is `state/validate_structure_...`.

## Temporary Workaround
- Redeploy host networking so `/etc/resolv.conf` points to a DNS server that can resolve GitHub (e.g., 1.1.1.1).  
- Confirm with `dig github.com` or `git ls-remote git@github.com:VizionCorpAI/vizion-infra.wiki.git`.  
- If DNS still fails, run from another network or coordinate with Hostinger to open outbound port 22/443.

## Learning note
Once connectivity is restored, rerun `scripts/wiki_sync.sh` (or DocOps) so we can publish the infra audit + learning updates.
