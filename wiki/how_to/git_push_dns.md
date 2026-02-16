# How To: fix GitHub DNS for wiki sync

## Trigger
`./scripts/wiki_sync.sh` or `docops_run.sh` stage fails before the clone because `ssh: Could not resolve hostname github.com`.

## Action
1. Inspect `/etc/resolv.conf` and ensure the DNS server is reachable; temporary fallback: add `nameserver 1.1.1.1`.  
2. Test resolution: `dig github.com` or `host github.com` must return an IP.  
3. Confirm SSH connectivity: `ssh -T git@github.com` (accept host key).  
4. Retry wiki sync and ensure `state/wiki-clone` now clones and pushes the latest markdown.

## Verification
- `git ls-remote git@github.com:VizionCorpAI/vizion-infra.wiki.git` returns the refs without error.  
- `scripts/wiki_sync.sh` exits normally and the wiki repo shows the new `Architecture-*` pages.
