# ZeroClaw Configuration

Personal configuration for my ZeroClaw AI agent running on nofiat.me

## About

This repository contains the sanitized configuration files for my [ZeroClaw](https://github.com/openagen/zeroclaw) autonomous AI assistant. ZeroClaw is a lightweight (~5MB RAM), Rust-based AI infrastructure that can be deployed anywhere.

**Deployment:** DigitalOcean droplet (164.92.236.31)
**Orchestrator:** Gemini 2.5 Flash via OpenRouter
**Researchers:** Perplexity Sonar variants via OpenRouter
**Channels:** Telegram bot
**Domain:** nofiat.me

## Repository Structure

```
zeroclaw-config/
├── config.example.toml          # Configuration template (fill in your API keys)
├── IDENTITY.md                  # Orchestrator behavior and routing rules
├── skills/                      # Researcher skill definitions
│   ├── generic-researcher.md    # Multi-source web research (sonar-pro-search)
│   ├── bitcoin-showcase.md      # BTC/Lightning project discovery (sonar-deep-research)
│   └── saas-opportunity.md      # AI-resistant SaaS ideas (sonar-reasoning)
└── setup/
    └── systemd/
        └── zeroclaw.service     # Systemd service configuration
```

## Architecture

The agent uses a multi-model architecture where an orchestrator delegates to specialized researchers:

```
User message
    │
    ▼
┌─────────────────────────────┐
│  Orchestrator (IDENTITY.md) │  ← google/gemini-2.5-flash
│  - Routes user intent       │
│  - Validates output quality │
│  - Iterates if gaps found   │
│  - Presents final result    │
└──────────┬──────────────────┘
           │ delegates to
           ▼
┌──────────────────────────────────────────────────────┐
│  Researcher Skills                                   │
│                                                      │
│  generic-researcher    → perplexity/sonar-pro-search │
│  bitcoin-showcase      → perplexity/sonar-deep-research │
│  saas-opportunity      → perplexity/sonar-reasoning  │
└──────────────────────────────────────────────────────┘
```

### Model Routes

| Route Hint     | Model                              | Purpose                       |
|----------------|------------------------------------|-------------------------------|
| (default)      | google/gemini-2.5-flash   | Orchestration, validation     |
| web-research   | perplexity/sonar-pro-search        | Generic multi-step research   |
| deep-research  | perplexity/sonar-deep-research     | Deep autonomous research (BTC)|
| analytical     | perplexity/sonar-reasoning         | Reasoning + web (SaaS)        |

Skills declare their model via `model_hint` in YAML frontmatter. The orchestrator runs on the default model and delegates to skills, which run on their hinted model.

## Quick Start

### Prerequisites

- Linux server (Ubuntu 22.04+ recommended)
- Rust installed (via rustup)
- OpenRouter API key ([get one here](https://openrouter.ai/keys))
- Optional: Telegram bot token (from [@BotFather](https://t.me/BotFather))

### Installation

1. **Install ZeroClaw:**
   ```bash
   # Using Homebrew
   brew install zeroclaw

   # Or from source
   git clone https://github.com/openagen/zeroclaw.git
   cd zeroclaw
   cargo build --release
   sudo cp target/release/zeroclaw /usr/local/bin/
   ```

2. **Set up configuration:**
   ```bash
   mkdir -p ~/.zeroclaw/workspace/skills

   # Copy and edit config
   cp config.example.toml ~/.zeroclaw/config.toml
   chmod 600 ~/.zeroclaw/config.toml

   # Fill in your API keys
   nano ~/.zeroclaw/config.toml
   ```

3. **Install skills and identity:**
   ```bash
   cp IDENTITY.md ~/.zeroclaw/workspace/
   cp skills/*.md ~/.zeroclaw/workspace/skills/
   ```

4. **Set up Telegram (optional):**
   ```bash
   # Get your Telegram user ID from @userinfobot
   # Add bot token and user ID to config.toml

   zeroclaw onboard --channels-only
   ```

5. **Test the agent:**
   ```bash
   zeroclaw agent -m "Find me a Bitcoin project to showcase"
   ```

### Systemd Service Setup (Production)

For running as a background service:

```bash
# Create zeroclaw user
sudo useradd -r -s /bin/false zeroclaw
sudo mkdir -p /home/zeroclaw/.zeroclaw
sudo cp -r ~/.zeroclaw/* /home/zeroclaw/.zeroclaw/
sudo chown -R zeroclaw:zeroclaw /home/zeroclaw

# Install service
sudo cp setup/systemd/zeroclaw.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable zeroclaw
sudo systemctl start zeroclaw

# Check status
sudo systemctl status zeroclaw
sudo journalctl -u zeroclaw -f
```

## Configuration Overview

### Key Settings

**Model Selection:**
- Orchestrator: `google/gemini-2.5-flash` — fast reasoning for routing and validation
- Researchers: Perplexity Sonar variants — each optimized for different research patterns
- All models accessed via OpenRouter (single API key)

**Autonomy Level:**
- `supervised`: Requires approval for medium-risk actions (recommended)
- `readonly`: Only reads, no system modifications
- `full`: Fully autonomous (use with caution)

**Safety Features:**
- Workspace-only file access
- Command allowlist (curl, grep, python3, etc.)
- Forbidden paths protection (/etc, /root, /usr, etc.)
- Rate limiting: 30 actions/hour, $5/day max cost

### Researcher Skills

**generic-researcher.md** (sonar-pro-search)
- Multi-source web research on any topic
- Self-validation: 2+ sources per finding, gap reporting
- Iterates on failed sources before reporting gaps

**bitcoin-showcase.md** (sonar-deep-research)
- Finds buildable Bitcoin/Lightning showcase projects (~1 month scope)
- Expanded sources: 12+ project repos, developer profiles, funding signals
- Feasibility filter: Rust path, real gap, showcase-worthy, solo-buildable

**saas-opportunity.md** (sonar-reasoning)
- AI-resistant micro-SaaS opportunity discovery
- Defensibility filter: data moat, integration depth, domain expertise, network effects
- Fixed sources (replaced broken MicroAcquire, IndieHackers endpoints)

## Usage Examples

### Via Telegram
Message your bot — the orchestrator routes to the appropriate researcher skill.

### Via CLI
```bash
# Bitcoin showcase project discovery
zeroclaw agent -m "Find me a Bitcoin project to showcase my Rust skills"

# SaaS opportunity research
zeroclaw agent -m "What micro-SaaS ideas have real defensibility right now?"

# General research
zeroclaw agent -m "Compare Lightning implementations for mobile wallets"

# Interactive session
zeroclaw agent --interactive
```

## Monitoring & Maintenance

### Check Logs
```bash
# Follow live logs
sudo journalctl -u zeroclaw -f

# Recent errors
sudo journalctl -u zeroclaw -n 50 -p err

# Today's activity
sudo journalctl -u zeroclaw --since today
```

### Restart Service
```bash
sudo systemctl restart zeroclaw
```

### Update Configuration
```bash
# Edit config
sudo nano /home/zeroclaw/.zeroclaw/config.toml

# Restart to apply
sudo systemctl restart zeroclaw
```

## Security Notes

Never commit these files:
- `config.toml` (contains API keys)
- `.secret_key` (encryption key)
- `auth-profiles.json` (authentication data)

Safe to share:
- `config.example.toml` (template without secrets)
- All skill files (`*.md`)
- `IDENTITY.md`
- Systemd service file

## Resources

- [ZeroClaw GitHub](https://github.com/openagen/zeroclaw)
- [OpenRouter Models](https://openrouter.ai/models)
- [ZeroClaw Documentation](https://github.com/openagen/zeroclaw/tree/main/docs)
- [Telegram Bot Setup](https://core.telegram.org/bots)

## License

Configuration files are personal and provided as-is for reference. ZeroClaw itself is open source.

---

**Deployment:** nofiat.me | **Contact:** Via Telegram bot
