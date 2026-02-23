---
name: saas-opportunity
description: Research AI-resistant micro-SaaS opportunities with defensibility filtering. Focuses on ideas that can't be replicated in a weekend with AI tools.
model_hint: analytical
---

# SaaS Opportunity Researcher

Finds validated micro-SaaS opportunities by analyzing market signals, then filters each idea through an AI-resistance test. Only reports opportunities with genuine defensibility.

## When to use

- User wants to find a new income stream or product idea
- User asks what micro-SaaS products are trending or gaining traction
- User wants to validate a product idea against real market signals
- Orchestrator delegates a SaaS/product research task

## Research protocol

1. Scan demand signals from sources below for recurring pain points
2. For each candidate idea, apply the AI-resistance filter
3. Only report ideas that pass at least 2 defensibility factors
4. Verify pricing signals — real users must be paying for something similar
5. Assess build complexity for a solo developer

## Sources

### Demand signals
```bash
# Hacker News "what do you pay for" threads
curl -s "https://hn.algolia.com/api/v1/search?query=what+do+you+pay+for&tags=story&hitsPerPage=5" | python3 -c "import sys,json; [print(h['title'],'-',h.get('url','')) for h in json.load(sys.stdin)['hits']]"

# Recent "Show HN" SaaS launches
curl -s "https://hn.algolia.com/api/v1/search?query=Show+HN+SaaS&tags=story&hitsPerPage=10" | python3 -c "import sys,json; [print(h['title']) for h in json.load(sys.stdin)['hits']]"

# HN "Ask HN" product/tool requests
curl -s "https://hn.algolia.com/api/v1/search?query=ask+hn+tool+for&tags=ask_hn&hitsPerPage=8" | python3 -c "import sys,json; [print(h['title']) for h in json.load(sys.stdin)['hits']]"
```

### Reddit signals
```bash
# r/SaaS pain points
curl -s "https://www.reddit.com/r/SaaS/search.json?q=pain+point+OR+wish+there+was&sort=top&t=month&limit=5" -H "User-Agent: zeroclaw-research/1.0" | python3 -c "import sys,json; [print(p['data']['title']) for p in json.load(sys.stdin)['data']['children']]"

# r/SideProject (what people are building)
curl -s "https://www.reddit.com/r/SideProject/hot.json?limit=8" -H "User-Agent: zeroclaw-research/1.0" | python3 -c "import sys,json; [print(p['data']['title']) for p in json.load(sys.stdin)['data']['children']]"

# r/Entrepreneur (market needs)
curl -s "https://www.reddit.com/r/Entrepreneur/search.json?q=need+tool+OR+looking+for+software&sort=new&limit=5" -H "User-Agent: zeroclaw-research/1.0" | python3 -c "import sys,json; [print(p['data']['title']) for p in json.load(sys.stdin)['data']['children']]"
```

### Product / market signals
```bash
# Product Hunt (via Perplexity summarization)
# Ask: "What are the trending developer tools on Product Hunt this week?"

# GitHub trending repositories
curl -s "https://api.github.com/search/repositories?q=stars:>100+pushed:>2025-01-01&sort=stars&per_page=10" | python3 -c "import sys,json; [print(r['full_name'], '-', r.get('description','')[:80]) for r in json.load(sys.stdin)['items']]"

# Acquire.com marketplace (what's selling)
# Ask: "What types of SaaS products are listed on acquire.com marketplace recently?"

# Twitter/X developer sentiment (via Perplexity summarization)
# Ask: "What SaaS tools are developers complaining about or requesting on Twitter/X this week?"
```

### Pricing validation
```bash
# HN Who's Hiring (what companies need)
curl -s "https://hn.algolia.com/api/v1/search?tags=ask_hn&query=who+is+hiring&hitsPerPage=1" | python3 -c "import sys,json; h=json.load(sys.stdin)['hits'][0]; print(h['objectID'], h['title'])"

# Lobsters (systems community needs)
curl -s "https://lobste.rs/search.json?q=TOPIC&what=stories&order=newest" | python3 -c "import sys,json; [print(s['title'], '-', s['url']) for s in json.load(sys.stdin)[:5]]"
```

## AI-resistance filter

For each candidate idea, ask:

> "Could a moderately technical person replicate this in a weekend using Claude Code or Codex?"

If yes — skip it. The idea has no moat.

An idea passes if it has 2+ of these defensibility factors:

1. **Data moat** — Product improves with proprietary data accumulated over time (user behavior, domain-specific datasets, feedback loops)
2. **Integration depth** — Deep API integrations, webhooks, compliance requirements, multi-system orchestration that takes months to build and maintain
3. **Domain expertise** — Requires regulated or niche domain knowledge (legal, medical, finance, supply chain, construction) that AI tools can't shortcut
4. **Network effects** — Value increases with user count (marketplace, community, shared workspace)
5. **Ongoing curation** — Requires continuous human judgment, monitoring, quality control, or content curation
6. **Infrastructure complexity** — Real-time processing, multi-service orchestration, edge computing, or hardware integration

For each idea, explicitly state which factors apply and why.

## Output format

For each qualifying opportunity:

1. **Problem** — What pain point, who experiences it, how often
2. **Why AI-resistant** — Which defensibility factors apply (with reasoning)
3. **Existing solutions** — What people use now and why it's insufficient
4. **Pricing signals** — What real users pay for similar tools (with sources)
5. **Build estimate** — Solo developer timeline, key technical challenges
6. **Entry strategy** — How to get first 10 paying customers

Plain text, inline citations (source: URL or platform).

End with: "Filtered out:" — ideas considered but failed the AI-resistance test, with brief explanation of why.
