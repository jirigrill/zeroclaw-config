---
name: research-coordinator
description: Conduct deep structured research based on a brief from Claude Code. Returns systematic findings.
---

# Research Coordinator

Handles structured research briefs sent by Claude Code. Conducts thorough web research and returns findings in a format that can be directly used by a developer.

## When to use

- Incoming message starts with "RESEARCH BRIEF" header
- Claude Code sends a structured multi-field brief for investigation
- User wants systematic research on a technical or ecosystem topic

## Brief format to expect

```
RESEARCH BRIEF
Topic: [main subject]
Context: [background — why this matters]
Focus areas:
  1. [specific question or aspect]
  2. [specific question or aspect]
  ...
Sources: [GitHub / HN / Delving / Optech / Bitcointalk / StackerNews / IndieHackers / Reddit / Freelance / all]
Depth: [quick-scan / deep-dive]
Output: [bullet-list / detailed / comparison-table]
```

## Research protocol

1. Parse the brief fields exactly — do not invent or expand scope
2. Fetch real-time data from the requested sources using curl
3. For GitHub topics: check issues, PRs, recent commits, contributor activity
4. For ecosystem topics: check forum threads, newsletter archives, social signals
5. For technical specs: fetch the actual spec/RFC/BIP/BOLT directly
6. Cross-reference at least 2 sources per focus area before reporting

## Key data sources

### Bitcoin / Lightning
```bash
# Delving Bitcoin (technical proposals)
curl -s "https://delvingbitcoin.org/latest.json" | python3 -c "import sys,json; [print(t['title'], '-', t['url']) for t in json.load(sys.stdin)['topic_list']['topics'][:8]]" 2>/dev/null || \
curl -s "https://delvingbitcoin.org/" | grep -oE '<a[^>]+href="/t/[^"]+">.*?</a>' | head -10

# Bitcoin Optech newsletter
curl -s "https://bitcoinops.org/en/newsletters/" | grep -oE 'Newsletter #[0-9]+[^<]*' | head -5

# Bitcoin mailing list
curl -s "https://groups.google.com/g/bitcoindev/feed/posts/atom/group?num=10" | grep -oE "<title>[^<]+</title>" | grep -v "^<title>Bitcoin" | head -10

# Bitcointalk announcements board
curl -s "https://bitcointalk.org/index.php?board=159.0" | grep -oE '<span id="msg_[0-9]+">[^<]{10,100}</span>' | head -8

# Stacker News (bitcoin HN clone)
curl -s "https://stacker.news/api/items?type=top" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); [print(i.get('title',''), '-', i.get('url','')) for i in d.get('items',d.get('stories',[]))[:8]]" 2>/dev/null || \
curl -s "https://stacker.news/" | grep -oE '<a[^>]+class="[^"]*item[^"]*"[^>]*>([^<]+)</a>' | head -10

# GitHub BIPs
curl -s "https://api.github.com/repos/bitcoin/bips/contents/" | python3 -c "import sys,json; [print(f['name']) for f in json.load(sys.stdin) if f['name'].startswith('bip')]" | tail -10

# GitHub BOLTs open issues
curl -s "https://api.github.com/repos/lightning/bolts/issues?state=open&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# LDK (Rust Lightning) good first issues
curl -s "https://api.github.com/repos/lightningdevkit/rust-lightning/issues?state=open&labels=good+first+issue&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# BDK good first issues
curl -s "https://api.github.com/repos/bitcoindevkit/bdk/issues?state=open&labels=good+first+issue&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"
```

### Solo builders / indie
```bash
# Hacker News (Algolia API)
curl -s "https://hn.algolia.com/api/v1/search?query=TOPIC&tags=story&hitsPerPage=8" | python3 -c "import sys,json; [print(h['title'], '-', h.get('url','')) for h in json.load(sys.stdin)['hits']]"

# IndieHackers (no public API — use search)
curl -s "https://www.indiehackers.com/search?q=TOPIC" | grep -oE '<h[23][^>]*>[^<]{10,100}</h[23]>' | head -8

# Reddit r/SideProject
curl -s "https://www.reddit.com/r/SideProject/search.json?q=TOPIC&sort=new&limit=5" -A "research-bot" | python3 -c "import sys,json; [print(p['data']['title'], '-', p['data']['url']) for p in json.load(sys.stdin)['data']['children']]"

# Reddit r/Entrepreneur
curl -s "https://www.reddit.com/r/Entrepreneur/search.json?q=TOPIC&sort=new&limit=5" -A "research-bot" | python3 -c "import sys,json; [print(p['data']['title']) for p in json.load(sys.stdin)['data']['children']]"
```

### Freelance / demand signals
```bash
# HN Who's Hiring (latest thread)
curl -s "https://hn.algolia.com/api/v1/search?tags=ask_hn&query=who+is+hiring&hitsPerPage=1" | python3 -c "import sys,json; h=json.load(sys.stdin)['hits'][0]; print(h['objectID'], h['title'])"

# GitHub repos with help-wanted
curl -s "https://api.github.com/search/repositories?q=TOPIC+language:rust&sort=updated&per_page=5" | python3 -c "import sys,json; [print(r['full_name'], '-', r['description']) for r in json.load(sys.stdin)['items']]"

# Reddit r/forhire
curl -s "https://www.reddit.com/r/forhire/search.json?q=TOPIC&sort=new&limit=5" -A "research-bot" | python3 -c "import sys,json; [print(p['data']['title']) for p in json.load(sys.stdin)['data']['children']]"
```

### General tech signals
```bash
# Twitter/X — use perplexity to summarize recent tweets on topic (no API key needed via sonar)
# Ask: "What are developers saying about TOPIC on Twitter/X in the last week?"

# Lobsters (systems/Rust community)
curl -s "https://lobste.rs/search.json?q=TOPIC&what=stories&order=newest" | python3 -c "import sys,json; [print(s['title'], '-', s['url']) for s in json.load(sys.stdin)[:5]]" 2>/dev/null

# Reddit r/rust
curl -s "https://www.reddit.com/r/rust/search.json?q=TOPIC&sort=new&limit=5" -A "research-bot" | python3 -c "import sys,json; [print(p['data']['title']) for p in json.load(sys.stdin)['data']['children']]"

# crates.io search
curl -s "https://crates.io/api/v1/crates?q=TOPIC&per_page=5" | python3 -c "import sys,json; [print(c['name'], '-', c.get('description','')) for c in json.load(sys.stdin)['crates']]"
```

## Output rules

- No markdown, plain text only
- Lead with a 2-3 sentence summary of the most important finding
- Then: findings per focus area, labeled with the focus area number
- Cite sources inline: (source: URL or platform name)
- End with: "Open questions:" listing gaps or things needing deeper research
- If depth=quick-scan: max 300 words total
- If depth=deep-dive: no word limit, stay structured, go through all focus areas

## Collaboration notes

Claude Code receives this output and synthesizes it further into developer-actionable conclusions. Focus on raw data and facts. Do not editorialize — report what you found and where you found it.
