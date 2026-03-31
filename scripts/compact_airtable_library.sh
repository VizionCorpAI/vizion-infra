#!/usr/bin/env bash
set -euo pipefail

LIB_DIR="${1:-/root/VizionAI/WORKSPACES/vizion-infra/airtable/library}"

python3 - "$LIB_DIR" <<'PY'
import csv
import pathlib
import sys

lib = pathlib.Path(sys.argv[1])

def rewrite(path, transform):
    rows = []
    with path.open(newline="", encoding="utf-8") as fh:
      reader = csv.DictReader(fh)
      fieldnames = reader.fieldnames or []
      for row in reader:
        rows.append(transform(row))
    with path.open("w", newline="", encoding="utf-8") as fh:
      writer = csv.DictWriter(fh, fieldnames=fieldnames, lineterminator="\n")
      writer.writeheader()
      writer.writerows(rows)

def first_clause(text, limit=180):
    text = (text or "").strip()
    if not text:
        return ""
    for sep in [". ", "\n", "; "]:
        idx = text.find(sep)
        if idx > 0:
            text = text[:idx + 1]
            break
    if len(text) > limit:
        return text[: limit - 1].rstrip() + "…"
    return text

def first_step(text, limit=220):
    text = (text or "").strip()
    if not text:
        return ""
    import re
    m = re.match(r"^\s*1\.\s*(.*?)(?:\s+\d+\.\s|$)", text, flags=re.S)
    if m and m.group(1).strip():
        text = m.group(1).strip()
    else:
        text = first_clause(text, limit)
    if len(text) > limit:
        return text[: limit - 1].rstrip() + "…"
    return text

articles = lib / "03_articles.csv"
if articles.exists():
    def compact_article(row):
        row["content"] = "Full article text stays in the local learning plane; use summary, tags, and source metadata here."
        return row
    rewrite(articles, compact_article)

signals = lib / "05_signals.csv"
if signals.exists():
    def compact_signal(row):
        src = (row.get("source_reference") or "").strip()
        row["raw_content"] = f"Compact mirror. Source reference: {src}" if src else "Compact mirror. Full payload stays in the local learning plane."
        return row
    rewrite(signals, compact_signal)

problems = lib / "02_problems.csv"
if problems.exists():
    def compact_problem(row):
        row["symptom"] = first_clause(row.get("symptom"), 160)
        row["root_cause"] = first_clause(row.get("root_cause"), 180)
        row["fix"] = first_step(row.get("fix"), 220)
        row["prevention"] = first_clause(row.get("prevention"), 180)
        return row
    rewrite(problems, compact_problem)

recommendations = lib / "04_recommendations.csv"
if recommendations.exists():
    def compact_recommendation(row):
        row["description"] = first_clause(row.get("description"), 200)
        row["impact"] = first_clause(row.get("impact"), 160)
        return row
    rewrite(recommendations, compact_recommendation)

prompts = lib / "06_prompts.csv"
if prompts.exists():
    def compact_prompt(row):
        agent = (row.get("agent") or "").strip()
        row["prompt_text"] = f"Compact mirror. Full prompt text stays in the local learning plane for {agent or 'this agent'}."
        return row
    rewrite(prompts, compact_prompt)
PY
