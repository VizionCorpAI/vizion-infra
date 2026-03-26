#!/usr/bin/env python3
"""
VizionAI Airtable Library — Linked Record Refresh
==================================================
Reads all 6 tables, builds ID lookup maps, then patches every record
with the correct linked-record IDs based on keyword and content matching.

Usage:
  export AIRTABLE_LIBRARY_TOKEN=pat_xxx...
  export AIRTABLE_LIBRARY_BASE_ID=appXXXXXXXXXXXXXX
  python3 link_records.py [--dry-run]

Dry-run prints what would be patched without making any API calls.
"""

import os, sys, re, time, json, argparse
import urllib.request, urllib.error, urllib.parse

# ── Config ────────────────────────────────────────────────────────────────────

TOKEN   = os.environ.get("AIRTABLE_LIBRARY_TOKEN", "")
BASE_ID = os.environ.get("AIRTABLE_LIBRARY_BASE_ID", "")

if not TOKEN or not BASE_ID:
    print("ERROR: Set AIRTABLE_LIBRARY_TOKEN and AIRTABLE_LIBRARY_BASE_ID environment variables.")
    sys.exit(1)

API_BASE   = f"https://api.airtable.com/v0/{BASE_ID}"
HEADERS    = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}
RATE_SLEEP = 0.25  # 4 req/sec — well under Airtable's 5/sec limit

# Table names exactly as they appear in your Airtable base
TABLES = {
    "articles":        "Articles",
    "problems":        "Problems",
    "recommendations": "Recommendations",
    "services":        "Services",
    "signals":         "Signals",
    "prompts":         "Prompts",
}

# ── HTTP helpers ──────────────────────────────────────────────────────────────

def api_get(path, params=None):
    url = f"{API_BASE}/{urllib.parse.quote(path, safe='')}"
    if params:
        url += "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read())

def api_patch(path, record_id, fields, dry_run=False):
    url = f"{API_BASE}/{urllib.parse.quote(path, safe='')}/{record_id}"
    payload = json.dumps({"fields": fields}).encode()
    if dry_run:
        print(f"  [DRY-RUN] PATCH {path}/{record_id}: {json.dumps(fields)[:120]}")
        return
    req = urllib.request.Request(url, data=payload, headers=HEADERS, method="PATCH")
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f"  ERROR patching {path}/{record_id}: {e.code} {body[:200]}")

def fetch_all(table_name):
    """Fetch every record from a table, handling pagination."""
    records = []
    offset  = None
    while True:
        params = {"pageSize": 100}
        if offset:
            params["offset"] = offset
        data   = api_get(table_name, params)
        records.extend(data.get("records", []))
        offset = data.get("offset")
        time.sleep(RATE_SLEEP)
        if not offset:
            break
    return records

# ── Load all tables ───────────────────────────────────────────────────────────

def load_tables():
    print("Fetching all tables from Airtable…")
    data = {}
    for key, name in TABLES.items():
        print(f"  → {name}")
        data[key] = fetch_all(name)
        print(f"     {len(data[key])} records")
    return data

# ── ID lookup helpers ─────────────────────────────────────────────────────────

def build_map(records, field):
    """Return {field_value.lower(): record_id} for fast lookup."""
    m = {}
    for r in records:
        val = r["fields"].get(field, "")
        if val:
            m[val.strip().lower()] = r["id"]
    return m

def find_ids(names_or_csv, lookup_map):
    """Given a comma-separated string or list of names, return matching record IDs."""
    if not names_or_csv:
        return []
    if isinstance(names_or_csv, str):
        names = [n.strip() for n in names_or_csv.split(",") if n.strip()]
    else:
        names = names_or_csv
    return [lookup_map[n.lower()] for n in names if n.lower() in lookup_map]

def keyword_match_ids(text, lookup_map, threshold=1):
    """Return IDs whose keys appear as substrings in text (case-insensitive)."""
    text_lower = (text or "").lower()
    return [rid for key, rid in lookup_map.items()
            if len(key) >= threshold and key in text_lower]

# ── Tag → Service name mapping ────────────────────────────────────────────────

TAG_TO_SERVICES = {
    "openclaw":    ["OpenClaw", "WhatsApp (OpenClaw Channel)"],
    "n8n":         ["n8n", "Alert Ingest Webhook", "EA AI Gateway", "Trade Trigger Webhook"],
    "postgresql":  ["PostgreSQL AIDB"],
    "mt5":         ["MT5 Demo Terminal", "MT5 Live Terminal", "MT5 Copytrade", "MT5 REST Server"],
    "trading":     ["EA AI Gateway", "Trade Trigger Webhook", "MT5 REST Server"],
    "caddy":       ["Caddy Reverse Proxy"],
    "telegram":    ["Telegram Bot"],
    "whatsapp":    ["WhatsApp (OpenClaw Channel)"],
    "gemini":      ["Gemini API (Google)"],
    "openrouter":  ["OpenRouter"],
    "infisical":   ["Infisical (Secrets)"],
    "monitoring":  ["Alert Ingest Webhook"],
    "networking":  ["Caddy Reverse Proxy"],
    "security":    ["Infisical (Secrets)"],
    "analytics":   ["NN Server"],
    "backup":      ["PostgreSQL AIDB"],
}

# Agent → Service mapping for Prompts table
AGENT_TO_SERVICES = {
    "workspace-router":  ["OpenClaw", "n8n"],
    "market-analyzer":   ["EA AI Gateway", "NN Server", "MT5 Demo Terminal"],
    "risk-checker":      ["EA AI Gateway", "MT5 Demo Terminal", "MT5 Live Terminal"],
    "resource-monitor":  ["OpenClaw", "n8n", "PostgreSQL AIDB", "Caddy Reverse Proxy",
                          "MT5 Demo Terminal", "MT5 Live Terminal", "NN Server"],
    "signal-classifier": ["Alert Ingest Webhook", "n8n"],
    "ea-gateway":        ["EA AI Gateway", "MT5 Demo Terminal", "MT5 Live Terminal", "MT5 REST Server"],
    "health-checker":    ["OpenClaw", "n8n", "PostgreSQL AIDB", "MT5 REST Server", "NN Server"],
}

# ── Linking logic per table ───────────────────────────────────────────────────

def link_problems_to_services(data, svc_name_map, dry_run):
    """Problems.affected_services (text CSV) → Services records."""
    print("\n[1/7] Problems → Services (via affected_services field)")
    linked = 0
    for r in data["problems"]:
        f   = r["fields"]
        raw = f.get("affected_services", "")
        ids = find_ids(raw, svc_name_map)
        if ids:
            print(f"  Problem: {f.get('title','?')[:60]} → {len(ids)} service(s)")
            api_patch(TABLES["problems"], r["id"], {"linked_services": ids}, dry_run)
            time.sleep(RATE_SLEEP)
            linked += 1
    print(f"  Done — {linked} problems linked to services")


def link_articles_to_services(data, svc_name_map, dry_run):
    """Articles: map tags → Services via TAG_TO_SERVICES lookup."""
    print("\n[2/7] Articles → Services (via tags)")
    linked = 0
    for r in data["articles"]:
        f    = r["fields"]
        tags = [t.strip().lower() for t in f.get("tags", "").split(",") if t.strip()]
        svc_ids = []
        for tag in tags:
            for svc_name in TAG_TO_SERVICES.get(tag, []):
                sid = svc_name_map.get(svc_name.lower())
                if sid and sid not in svc_ids:
                    svc_ids.append(sid)
        if svc_ids:
            print(f"  Article: {f.get('title','?')[:60]} → {len(svc_ids)} service(s)")
            api_patch(TABLES["articles"], r["id"], {"linked_services": svc_ids}, dry_run)
            time.sleep(RATE_SLEEP)
            linked += 1
    print(f"  Done — {linked} articles linked to services")


def link_articles_to_problems(data, prob_title_map, dry_run):
    """
    Articles → Problems: match by shared category/tags.
    Runbooks/how-tos with 'mt5' tag link to mt5 problems, etc.
    """
    print("\n[3/7] Articles → Problems (via category + tags)")

    # tag/keyword → problem title keywords to match
    TAG_PROBLEM_KEYWORDS = {
        "openclaw":   ["openclaw"],
        "n8n":        ["n8n"],
        "mt5":        ["mt5", "wine", "socat", "numpy"],
        "openrouter": ["openrouter"],
        "gemini":     ["openclaw telegram", "google provider"],
    }

    linked = 0
    for r in data["articles"]:
        f    = r["fields"]
        tags = [t.strip().lower() for t in f.get("tags", "").split(",") if t.strip()]
        cat  = f.get("category", "").lower()

        # skip pure architecture / decision records (no problem linkage needed)
        if cat in ("architecture", "decision-record"):
            continue

        prob_ids = []
        for tag in tags:
            for kw in TAG_PROBLEM_KEYWORDS.get(tag, []):
                for title_lower, pid in prob_title_map.items():
                    if kw in title_lower and pid not in prob_ids:
                        prob_ids.append(pid)

        if prob_ids:
            print(f"  Article: {f.get('title','?')[:60]} → {len(prob_ids)} problem(s)")
            api_patch(TABLES["articles"], r["id"], {"linked_problems": prob_ids}, dry_run)
            time.sleep(RATE_SLEEP)
            linked += 1
    print(f"  Done — {linked} articles linked to problems")


def link_recommendations_to_articles(data, art_title_map, dry_run):
    """Recommendations → Articles: keyword search in recommendation title + description."""
    print("\n[4/7] Recommendations → Articles (via keyword match)")

    # For each recommendation, search article titles for keyword overlap
    linked = 0
    for r in data["recommendations"]:
        f     = r["fields"]
        title = (f.get("title", "") + " " + f.get("description", "")).lower()

        art_ids = []
        for art_lower, aid in art_title_map.items():
            # Use first 4 meaningful words of article title as match keywords
            words = [w for w in art_lower.split() if len(w) > 4][:4]
            if any(w in title for w in words) and aid not in art_ids:
                art_ids.append(aid)

        if art_ids:
            print(f"  Rec: {f.get('title','?')[:60]} → {len(art_ids)} article(s)")
            api_patch(TABLES["recommendations"], r["id"], {"linked_articles": art_ids}, dry_run)
            time.sleep(RATE_SLEEP)
            linked += 1
    print(f"  Done — {linked} recommendations linked to articles")


def link_recommendations_to_problems(data, prob_title_map, dry_run):
    """Recommendations → Problems: keyword match on recommendation title."""
    print("\n[5/7] Recommendations → Problems (via keyword match)")

    REC_PROBLEM_KW = {
        "openrouter":  ["openrouter"],
        "mt5":         ["mt5", "wine", "socat", "numpy"],
        "openclaw":    ["openclaw"],
        "n8n":         ["n8n"],
        "airtable":    [],
        "infisical":   [],
    }

    linked = 0
    for r in data["recommendations"]:
        f     = r["fields"]
        title = (f.get("title", "") + " " + f.get("description", "")).lower()

        prob_ids = []
        for kw_group, kws in REC_PROBLEM_KW.items():
            if kw_group not in title:
                continue
            for kw in (kws or [kw_group]):
                for prob_lower, pid in prob_title_map.items():
                    if kw in prob_lower and pid not in prob_ids:
                        prob_ids.append(pid)

        if prob_ids:
            print(f"  Rec: {f.get('title','?')[:60]} → {len(prob_ids)} problem(s)")
            api_patch(TABLES["recommendations"], r["id"], {"linked_problems": prob_ids}, dry_run)
            time.sleep(RATE_SLEEP)
            linked += 1
    print(f"  Done — {linked} recommendations linked to problems")


def link_signals(data, art_title_map, prob_title_map, rec_title_map, dry_run):
    """Signals → Articles/Problems/Recommendations via resulted_in + keyword match."""
    print("\n[6/7] Signals → Articles / Problems / Recommendations")

    linked = 0
    for r in data["signals"]:
        f       = r["fields"]
        result  = f.get("resulted_in", "").lower()
        summary = (f.get("summary", "") + " " + f.get("raw_content", "")).lower()
        patch   = {}

        if result == "article":
            ids = keyword_match_ids(summary, art_title_map, threshold=5)[:1]
            if ids:
                patch["linked_article"] = ids
        elif result == "problem":
            ids = keyword_match_ids(summary, prob_title_map, threshold=5)[:1]
            if ids:
                patch["linked_problem"] = ids
        elif result == "recommendation":
            ids = keyword_match_ids(summary, rec_title_map, threshold=5)[:1]
            if ids:
                patch["linked_recommendation"] = ids

        if patch:
            print(f"  Signal: {f.get('summary','?')[:60]} → {list(patch.keys())}")
            api_patch(TABLES["signals"], r["id"], patch, dry_run)
            time.sleep(RATE_SLEEP)
            linked += 1
    print(f"  Done — {linked} signals linked")


def link_prompts_to_services(data, svc_name_map, dry_run):
    """Prompts → Services via AGENT_TO_SERVICES mapping."""
    print("\n[7/7] Prompts → Services (via agent field)")

    linked = 0
    for r in data["prompts"]:
        f     = r["fields"]
        agent = f.get("agent", "").lower().strip()

        svc_names = AGENT_TO_SERVICES.get(agent, [])
        svc_ids   = [svc_name_map[n.lower()] for n in svc_names
                     if n.lower() in svc_name_map]

        if svc_ids:
            print(f"  Prompt: {f.get('name','?')[:50]} (agent={agent}) → {len(svc_ids)} service(s)")
            api_patch(TABLES["prompts"], r["id"], {"linked_services": svc_ids}, dry_run)
            time.sleep(RATE_SLEEP)
            linked += 1
    print(f"  Done — {linked} prompts linked to services")


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true",
                        help="Print what would be changed without calling the API")
    args = parser.parse_args()

    if args.dry_run:
        print("=== DRY RUN MODE — no changes will be made ===\n")

    # Load all tables
    data = load_tables()

    # Build lookup maps: lower(name/title) → record ID
    svc_name_map  = build_map(data["services"],        "name")
    prob_title_map = build_map(data["problems"],       "title")
    art_title_map  = build_map(data["articles"],       "title")
    rec_title_map  = build_map(data["recommendations"],"title")

    print(f"\nLookup maps built:")
    print(f"  Services:        {len(svc_name_map)} entries")
    print(f"  Problems:        {len(prob_title_map)} entries")
    print(f"  Articles:        {len(art_title_map)} entries")
    print(f"  Recommendations: {len(rec_title_map)} entries")

    # Run all linking passes
    link_problems_to_services(data, svc_name_map, args.dry_run)
    link_articles_to_services(data, svc_name_map, args.dry_run)
    link_articles_to_problems(data, prob_title_map, args.dry_run)
    link_recommendations_to_articles(data, art_title_map, args.dry_run)
    link_recommendations_to_problems(data, prob_title_map, args.dry_run)
    link_signals(data, art_title_map, prob_title_map, rec_title_map, args.dry_run)
    link_prompts_to_services(data, svc_name_map, args.dry_run)

    print("\n✓ All linking passes complete.")
    if args.dry_run:
        print("  Run without --dry-run to apply changes.")


if __name__ == "__main__":
    main()
