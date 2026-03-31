# Web Capture with crawl4ai

Use `crawl4ai` when we need to turn public web pages into compact, source-linked
notes that can flow into the learning plane, analytics, or a downstream Airtable
summary.

## Best Fit

- `vizion-infra`: capture docs, vendor pages, issue writeups, and architecture
  references into the learning plane.
- `vizion-trading`: capture public news, macro commentary, broker pages, and
  strategy articles before they become trading summaries.
- `vizion-marketing`: capture competitor sites, landing pages, social profiles,
  and campaign pages for research and content planning.
- `vizion-security`: capture advisories, vendor bulletins, and threat intel
  pages into compact findings.
- `vizion-platform`: capture onboarding pages, public docs, and workspace
  references for routing and setup work.

## When To Use It

- The page is public or can be fetched without interactive login.
- The goal is to extract readable text, headings, links, and metadata from a
  page or a short list of pages.
- We want a structured summary instead of a raw HTML dump.
- We plan to promote the result into the learning plane, Airtable library, or a
  workspace-specific summary table.

## When Not To Use It

- The target is behind a real login flow and needs a human-like browser session
  or active interaction.
- The page is mostly app state rendered after many client-side interactions and
  simple crawling will miss the important content.
- We need exact screenshots, pixel-level evidence, or long session replay.
- The page contains secrets, private tokens, or personal data that should stay
  out of the learning plane.

## Recommended Workflow

1. Collect a small, explicit URL set.
2. Crawl each page with `crawl4ai` and extract:
   - title
   - canonical URL
   - publication or update date, when available
   - readable markdown or cleaned text
   - outbound links
   - source metadata
3. Summarize the result into a short note.
4. Add tags for workspace, topic, and source type.
5. Store the compact result in the learning plane first.
6. Promote only the condensed version into Airtable or another workspace view.

## Output Shape

Prefer a compact record like this:

```text
source_ref: https://example.com/article
workspace: vizion-trading
topic: news
summary: Short explanation of why the page matters.
tags: news, macro, trading
confidence: high
captured_at: 2026-03-30T00:00:00Z
```

Keep the raw page content out of Airtable and out of long-lived summary tables.

## Workspace Patterns

- News monitors can crawl article pages, extract the core thesis, and feed the
  result into trading review queues.
- Content pipelines can crawl competitor and market pages, then turn them into
  outlines, angles, or research notes.
- Onboarding and platform work can crawl public docs and product pages to build
  workspace-specific setup notes.
- Security workflows can crawl advisories and vendor notices, then promote only
  the compact risk summary.

## Operational Notes

- Run `crawl4ai` from a Python-capable utility environment, not from MT5 or
  other trading runtime processes.
- Prefer a small batch size so extraction failures are easy to debug.
- Preserve source links so every note can be traced back to the original page.
- If the page is heavily script-driven, fall back to browser-style capture or a
  different browser automation tool.

## Sources

- `crawl4ai` project docs and examples
- VizionAI learning-plane workflow conventions
