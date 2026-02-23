---
name: generic-researcher
description: Conduct multi-source web research on any topic. Iterates until findings are validated.
model_hint: web-research
---

# Generic Researcher

Performs structured web research on any topic delegated by the orchestrator. Accepts natural language tasks or structured briefs. Iterates on sources until findings meet quality thresholds.

## When to use

- Orchestrator delegates a general research task
- Topic does not fit bitcoin-showcase or saas-opportunity scopes
- User wants systematic research on a technical or ecosystem topic
- Incoming message contains a structured research brief

## Research protocol

1. Parse the task — identify focus areas, constraints, and desired depth
2. Select relevant sources from the catalog below based on topic
3. For each focus area, gather findings from at least 2 independent sources
4. If a source returns empty or errors, try an alternative before reporting a gap
5. Cross-reference findings — flag contradictions between sources

## Source catalog

### Bitcoin / Lightning
```bash
# Delving Bitcoin (technical proposals)
curl -s "https://delvingbitcoin.org/latest.json" | python3 -c "import sys,json; [print(t['title'], '-', t['url']) for t in json.load(sys.stdin)['topic_list']['topics'][:8]]"

# Bitcoin Optech newsletter
curl -s "https://bitcoinops.org/en/newsletters/" | grep -oE 'Newsletter #[0-9]+[^<]*' | head -5

# Bitcoin mailing list
curl -s "https://groups.google.com/g/bitcoindev/feed/posts/atom/group?num=10" | grep -oE "<title>[^<]+</title>" | grep -v "^<title>Bitcoin" | head -10

# Stacker News
curl -s "https://stacker.news/" | grep -oE '<a[^>]+class="[^"]*item[^"]*"[^>]*>([^<]+)</a>' | head -10

# GitHub BOLTs open issues
curl -s "https://api.github.com/repos/lightning/bolts/issues?state=open&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"
```

### Developer ecosystem
```bash
# Hacker News (Algolia API)
curl -s "https://hn.algolia.com/api/v1/search?query=TOPIC&tags=story&hitsPerPage=8" | python3 -c "import sys,json; [print(h['title'], '-', h.get('url','')) for h in json.load(sys.stdin)['hits']]"

# Lobsters (systems/Rust community)
curl -s "https://lobste.rs/search.json?q=TOPIC&what=stories&order=newest" | python3 -c "import sys,json; [print(s['title'], '-', s['url']) for s in json.load(sys.stdin)[:5]]"

# Reddit (add appropriate subreddit)
curl -s "https://www.reddit.com/r/SUBREDDIT/search.json?q=TOPIC&sort=new&limit=5" -H "User-Agent: zeroclaw-research/1.0" | python3 -c "import sys,json; [print(p['data']['title']) for p in json.load(sys.stdin)['data']['children']]"

# GitHub repository search
curl -s "https://api.github.com/search/repositories?q=TOPIC+language:rust&sort=updated&per_page=5" | python3 -c "import sys,json; [print(r['full_name'], '-', r['description']) for r in json.load(sys.stdin)['items']]"

# crates.io search
curl -s "https://crates.io/api/v1/crates?q=TOPIC&per_page=5" | python3 -c "import sys,json; [print(c['name'], '-', c.get('description','')) for c in json.load(sys.stdin)['crates']]"
```

### Freelance / demand signals
```bash
# HN Who's Hiring (latest thread)
curl -s "https://hn.algolia.com/api/v1/search?tags=ask_hn&query=who+is+hiring&hitsPerPage=1" | python3 -c "import sys,json; h=json.load(sys.stdin)['hits'][0]; print(h['objectID'], h['title'])"

# Reddit r/forhire
curl -s "https://www.reddit.com/r/forhire/search.json?q=TOPIC&sort=new&limit=5" -H "User-Agent: zeroclaw-research/1.0" | python3 -c "import sys,json; [print(p['data']['title']) for p in json.load(sys.stdin)['data']['children']]"
```

## Self-validation checklist

Before returning results, verify:

- [ ] Each focus area has findings from 2+ independent sources
- [ ] All URLs and claims are from actual source responses (not hallucinated)
- [ ] Gaps are explicitly noted with "No findings from [source] on this topic"
- [ ] Contradictions between sources are flagged
- [ ] Findings are specific enough for a developer to act on

If any check fails, retry with alternative sources before returning.

## Output format

Plain text only. Structure:

1. Summary — 2-3 sentences on the most important finding
2. Findings per focus area — labeled by area, inline citations (source: URL)
3. Open questions — gaps or areas needing deeper investigation
