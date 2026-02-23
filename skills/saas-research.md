---
name: saas-research
description: Research micro-SaaS opportunities, underserved niches, and validated product ideas.
---

# Micro-SaaS Research

Finds validated micro-SaaS opportunities by analyzing what developers and small businesses are paying for, complaining about, or requesting.

## When to use

- User wants to find a new income stream or product idea
- User asks what micro-SaaS products are trending or gaining traction
- User wants to validate a product idea against real market signals
- User asks about pricing, customer acquisition, or competition analysis

## Key sources to check

```bash
# Hacker News "Ask HN: What do you pay for?" threads
curl -s "https://hn.algolia.com/api/v1/search?query=what+do+you+pay+for&tags=story&hitsPerPage=5" | python3 -c "import sys,json; [print(h['title'],'-',h['url']) for h in json.load(sys.stdin)['hits']]"

# IndieHackers trending products
curl -s "https://www.indiehackers.com/products?sorting=revenue" | grep -oE '"name":"[^"]{3,40}"' | head -10

# Recent "Show HN" SaaS launches
curl -s "https://hn.algolia.com/api/v1/search?query=Show+HN+SaaS&tags=story&hitsPerPage=10" | python3 -c "import sys,json; [print(h['title']) for h in json.load(sys.stdin)['hits']]"

# Reddit SaaS pain points
curl -s "https://www.reddit.com/r/SaaS/search.json?q=pain+point+OR+wish+there+was&sort=top&t=month&limit=5" -H "User-Agent: research-bot/1.0" | python3 -c "import sys,json; [print(p['data']['title']) for p in json.load(sys.stdin)['data']['children']]"

# Micro-acquisitions marketplace (what's selling)
curl -s "https://microacquire.com/marketplace" | grep -oE '"title":"[^"]{5,60}"' | head -10
```

## Agent prompt

When researching micro-SaaS opportunities:
1. Look for recurring pain points mentioned by multiple people
2. Prioritize niches where users already pay for inferior solutions
3. Note pricing signals (what they pay, how often)
4. Highlight developer-focused tools (easiest to build and reach)
5. Return as: problem description, target customer, existing solutions and their weaknesses, rough pricing signal
