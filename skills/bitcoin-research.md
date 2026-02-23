---
name: bitcoin-research
description: Research Bitcoin and Lightning Network projects, developer activity, and ecosystem news.
---

# Bitcoin & Lightning Research

Researches current Bitcoin/Lightning developer activity, open issues, funded projects, and upcoming protocol changes.

## When to use

- User asks about Bitcoin or Lightning projects to work on or contribute to
- User wants to know what problems are unsolved in the ecosystem
- User asks about grant opportunities, hackathons, or funded work
- User wants to understand current protocol proposals (BIPs, BOLTs, BLIPs)

## Key sources to check

```bash
# Bitcoin developer mailing list (recent discussions)
curl -s "https://groups.google.com/g/bitcoindev/feed/posts/atom/group?num=10" | grep -oE "<title>[^<]+</title>" | head -10

# Bitcoin Optech newsletter (weekly ecosystem roundup)
curl -s "https://bitcoinops.org/en/newsletters/" | grep -oE "Newsletter #[0-9]+" | head -5

# Delving Bitcoin forum (technical proposals)
curl -s "https://delvingbitcoin.org/" | grep -oE "<h[23][^>]*>[^<]{10,80}</h[23]>" | head -10

# Lightning RFC open issues (what's being worked on)
curl -s "https://api.github.com/repos/lightning/bolts/issues?state=open&per_page=5" | python3 -c "import sys,json; [print(i['title']) for i in json.load(sys.stdin)]"

# LDK (Rust Lightning) recent issues
curl -s "https://api.github.com/repos/lightningdevkit/rust-lightning/issues?state=open&labels=good+first+issue&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"

# BDK (Bitcoin Dev Kit) good first issues
curl -s "https://api.github.com/repos/bitcoindevkit/bdk/issues?state=open&labels=good+first+issue&per_page=5" | python3 -c "import sys,json; [print(i['title'], '-', i['html_url']) for i in json.load(sys.stdin)]"
```

## Agent prompt

When researching Bitcoin/Lightning topics:
1. Check real-time sources above for current state
2. Focus on what is unsolved or needs contributors
3. Highlight Rust-friendly projects (LDK, BDK, rust-bitcoin, rust-lightning)
4. Note funding availability (OpenSats, Spiral, Brink, Maelstrom grants)
5. Return findings as a plain list: project name, what it needs, funding status
