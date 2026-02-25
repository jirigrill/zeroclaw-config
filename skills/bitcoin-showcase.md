---
name: bitcoin-showcase
description: Find buildable Bitcoin/Lightning showcase projects demonstrating Rust + BTC competence. Targets ~1 month solo builds.
model_hint: analytical
---

# Bitcoin Showcase Researcher

Finds ideas for standalone Bitcoin/Lightning projects buildable in ~1 month by a solo Rust developer. The goal is showcase projects that demonstrate meaningful technical skill — not just contribution opportunities to existing repos.

## When to use

- User asks about Bitcoin/Lightning projects to build or showcase
- User wants to demonstrate Rust + BTC competence
- User asks about ecosystem gaps, tooling needs, or buildable ideas
- Orchestrator delegates a BTC project discovery task

## Research protocol

1. Scan project repos for open gaps, missing tooling, and feature requests
2. Check developer profiles for what they're building or requesting
3. Review blogs/newsletters for trending areas and unmet needs
4. Cross-reference with funding signals to validate demand
5. Apply the feasibility filter to each candidate idea
6. Return only ideas that pass all filter criteria

## Sources

### Major project repos (watch for gaps, tooling needs, feature requests)
```bash
# Fedimint
curl -s "https://api.github.com/repos/fedimint/fedimint/issues?state=open&labels=good+first+issue&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# Cashu CDK
curl -s "https://api.github.com/repos/cashubtc/cdk/issues?state=open&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# Core Lightning
curl -s "https://api.github.com/repos/ElementsProject/lightning/issues?state=open&labels=good+first+issue&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# Eclair
curl -s "https://api.github.com/repos/ACINQ/eclair/issues?state=open&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# Phoenixd
curl -s "https://api.github.com/repos/ACINQ/phoenixd/issues?state=open&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# rust-bitcoin
curl -s "https://api.github.com/repos/rust-bitcoin/rust-bitcoin/issues?state=open&labels=good+first+issue&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# rust-miniscript
curl -s "https://api.github.com/repos/rust-bitcoin/rust-miniscript/issues?state=open&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# rust-payjoin
curl -s "https://api.github.com/repos/payjoin/rust-payjoin/issues?state=open&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# LDK (Rust Lightning)
curl -s "https://api.github.com/repos/lightningdevkit/rust-lightning/issues?state=open&labels=good+first+issue&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# BDK (Bitcoin Dev Kit)
curl -s "https://api.github.com/repos/bitcoindevkit/bdk/issues?state=open&labels=good+first+issue&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# Nostr (rust-nostr)
curl -s "https://api.github.com/repos/rust-nostr/nostr/issues?state=open&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# Nostr SDK
curl -s "https://api.github.com/repos/rust-nostr/nostr-sdk/issues?state=open&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"
```

### Developer profiles to monitor
Check recent activity, repos, and discussions from:
- sipa, TheBlueMatt, arik-so, benthecarman, jb55, fiatjaf, setavenger, paulmillr

```bash
# Example: check recent repos/activity
curl -s "https://api.github.com/users/USERNAME/repos?sort=updated&per_page=3" | python3 -c "import sys,json; [print(r['name'], '-', r.get('description','')) for r in json.load(sys.stdin)]"
```

### Blogs and newsletters
```bash
# Bitcoin Optech
curl -s "https://bitcoinops.org/en/newsletters/" | grep -oE 'Newsletter #[0-9]+[^<]*' | head -5

# Chaincode Labs blog
curl -s "https://chaincodelabs.com/blog" | grep -oE '<h[23][^>]*>[^<]{10,100}</h[23]>' | head -5

# LDK blog
curl -s "https://lightningdevkit.org/blog/" | grep -oE '<h[23][^>]*>[^<]{10,100}</h[23]>' | head -5

# Jimmy Song (via Perplexity summarization)
# Ask: "What has Jimmy Song written about recently on jimmysong.medium.com?"

# Bitcoin Magazine technical
# Ask: "What are the latest technical articles on bitcoinmagazine.com/technical?"

# Lopp's Bitcoin Information
# Reference: https://lopp.net/bitcoin-information
```

### Community forums
```bash
# Delving Bitcoin
curl -s "https://delvingbitcoin.org/latest.json" | python3 -c "import sys,json; [print(t['title'], '-', t['url']) for t in json.load(sys.stdin)['topic_list']['topics'][:8]]"

# Bitcoin StackExchange (recent questions)
curl -s "https://api.stackexchange.com/2.3/questions?order=desc&sort=activity&site=bitcoin&pagesize=5" | python3 -c "import sys,json; [print(q['title']) for q in json.load(sys.stdin)['items']]"

# Stacker News
curl -s "https://stacker.news/" | grep -oE '<a[^>]+class="[^"]*item[^"]*"[^>]*>([^<]+)</a>' | head -10

# Bitcointalk Development & Technical Discussion
curl -s "https://bitcointalk.org/index.php?board=6.0" | grep -oE '<span id="msg_[0-9]+">[^<]{10,100}</span>' | head -8
```

### Funding signals (validate project has backing potential)
```bash
# OpenSats grants
# Reference: https://opensats.org/grants — check what types of projects get funded

# Spiral
# Reference: https://spiral.xyz — check funded projects list

# Brink
# Reference: https://brink.dev — check fellowship and grant recipients

# Maelstrom Fund
# Reference: https://maelstrom.fund — check portfolio/grants

# HRF Bitcoin Development Fund
# Ask: "What projects has Human Rights Foundation funded for Bitcoin development?"
```

### Conference topics (trending areas)
Check recent talk topics and accepted proposals from:
- Bitcoin++ (btcplusplus.dev)
- TABConf
- Advancing Bitcoin

## Feasibility filter

Each project idea MUST pass ALL of these criteria:

1. **Buildable in ~4 weeks** by one developer working part-time? If the scope is larger, can it be meaningfully scoped down?
2. **Uses Rust** or has a clear Rust integration path (Rust bindings, Rust CLI wrapper, etc.)?
3. **Fills a real gap** — not duplicating an existing maintained tool? Check crates.io and GitHub before claiming a gap.
4. **Showcase-worthy** — demonstrates meaningful technical skill? (protocol implementation, cryptographic operations, network programming — not just a REST API wrapper)

Ideas that fail any criterion should be noted as "considered but filtered" with the reason.

## Output format

For each qualifying project idea:

1. Project name / one-line description
2. What gap it fills (with source citations)
3. Technical approach (key crates, protocols involved)
4. Feasibility assessment (scope, complexity, unknowns)
5. Funding potential (which grants/programs might support it)
6. Similar existing work (and why this is different)

End with: "Filtered out:" — brief list of ideas considered but rejected, with reasons.
