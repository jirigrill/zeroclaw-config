# ZeroClaw Configuration

Personal configuration for my ZeroClaw AI agent running on nofiat.me

## About

This repository contains the sanitized configuration files for my [ZeroClaw](https://github.com/openagen/zeroclaw) autonomous AI assistant. ZeroClaw is a lightweight (~5MB RAM), Rust-based AI infrastructure that can be deployed anywhere.

**Deployment:** DigitalOcean droplet (164.92.236.31)
**Model:** Perplexity Sonar via OpenRouter
**Channels:** Telegram bot
**Domain:** nofiat.me

## Repository Structure

```
zeroclaw-config/
├── config.example.toml          # Configuration template (fill in your API keys)
├── IDENTITY.md                  # Agent personality and behavior rules
├── skills/                      # Custom skill definitions
│   ├── bitcoin-research.md      # Bitcoin/Lightning ecosystem research
│   ├── saas-research.md         # Micro-SaaS opportunity research
│   └── research-coordinator.md  # Structured research protocol
└── setup/
    └── systemd/
        └── zeroclaw.service     # Systemd service configuration
```

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
   zeroclaw agent -m "Hello, test message"
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
- Using `perplexity/sonar` for fast, web-connected research
- Alternative: `anthropic/claude-sonnet-4-6` for complex reasoning

**Autonomy Level:**
- `supervised`: Requires approval for medium-risk actions (recommended)
- `readonly`: Only reads, no system modifications
- `full`: Fully autonomous (use with caution)

**Safety Features:**
- Workspace-only file access
- Command allowlist (curl, grep, python3, etc.)
- Forbidden paths protection (/etc, /root, /usr, etc.)
- Rate limiting: 30 actions/hour, $5/day max cost

### Custom Skills

**bitcoin-research.md**
- Monitors Bitcoin/Lightning developer activity
- Tracks funding opportunities (OpenSats, Spiral)
- Focuses on Rust projects (LDK, BDK, rust-bitcoin)

**saas-research.md**
- Identifies micro-SaaS opportunities
- Analyzes market signals and pain points
- Tracks validated product ideas

**research-coordinator.md**
- Handles structured research briefs
- Systematic multi-source research protocol
- Returns actionable, developer-focused findings

## Usage Examples

### Via Telegram
Just message your bot - it will respond using the configured model and skills.

### Via CLI
```bash
# Single message
zeroclaw agent -m "What Bitcoin projects need Rust developers?"

# Interactive session
zeroclaw agent --interactive
```

### Research Brief Format
```
RESEARCH BRIEF
Topic: Silent Payments implementation
Context: BIP352 needs scanning infrastructure
Focus areas:
  1. Existing implementations and their limitations
  2. Open issues and contribution opportunities
  3. Funding availability
Sources: GitHub / Delving / Optech
Depth: deep-dive
Output: detailed
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

### Switch Models
Edit `/home/zeroclaw/.zeroclaw/config.toml`:
```toml
default_model = "anthropic/claude-sonnet-4-6"  # For complex reasoning
# default_model = "perplexity/sonar"           # For fast research
```
Then restart the service.

## Security Notes

⚠️ **Never commit these files:**
- `config.toml` (contains API keys)
- `.secret_key` (encryption key)
- `auth-profiles.json` (authentication data)

✅ **Safe to share:**
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
