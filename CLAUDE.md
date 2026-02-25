# ZeroClaw Config Repository

Configuration files for a ZeroClaw AI agent deployed at nofiat.me. This is NOT a code project — it's a config repo containing TOML config, Markdown identity/skills, and a systemd service file.

## Architecture

Multi-model orchestrator pattern via OpenRouter:

- **Orchestrator** (IDENTITY.md): `anthropic/claude-haiku-4.5` — strong calibration for validation, efficient routing
- **Researchers** (skills/): each skill declares a `model_hint` in YAML frontmatter that maps to a `[[model_routes]]` entry in config

| Skill file | model_hint | Model | Status |
|---|---|---|---|
| bitcoin-showcase.md | analytical | perplexity/sonar-reasoning | Active |
| saas-opportunity.md | analytical | perplexity/sonar-reasoning | Active |
| generic-researcher.md | web-research | — | **DISABLED** (file kept, route removed) |

## File conventions

- **config.example.toml**: TOML config template. `config.toml` (with real keys) is gitignored. Validate changes with: `python3 -c "import tomllib; tomllib.load(open('config.example.toml','rb'))"`
- **IDENTITY.md**: Orchestrator behavior — routing table, validation protocol, presentation rules. Plain text output, no markdown.
- **skills/*.md**: Each skill has YAML frontmatter (`name`, `description`, `model_hint`) followed by Markdown body with research protocol, sources, and output format.

## Credentials management

On production server at `/home/zeroclaw/.zeroclaw/`:
- **config.toml**: Live config with all API keys and passwords (not tracked in git, .gitignored)
- **.env**: Backup of all credentials in `KEY=VALUE` format for future reference
  - `ZEROCLAW_OPENROUTER_API_KEY`: OpenRouter API key
  - `ZEROCLAW_TELEGRAM_BOT_TOKEN`: Telegram bot token
  - `ZEROCLAW_TELEGRAM_USER_ID`: Your Telegram user ID
  - `ZEROCLAW_IRC_NICK`: Your IRC nickname (for allowed_users)
  - `ZEROCLAW_IRC_PASSWORD`: IRC SASL password

Never commit config.toml, .env, or .secret_key — these contain live credentials.

## Key constraints

- Skills must have valid YAML frontmatter with all three fields: `name`, `description`, `model_hint`
- Every `model_hint` value must have a matching `[[model_routes]]` entry in config.example.toml
- Every **active** skill must be referenced in IDENTITY.md's routing table
- Disabled skills: keep the file, but remove route from config and routing table
- Skill output format is plain text with inline citations — no markdown
- Never commit `config.toml`, `.env`, `.secret_key`, or `auth-profiles.json` — these contain live credentials

## Verification after changes

```bash
# TOML syntax
python3 -c "import tomllib; tomllib.load(open('config.example.toml','rb'))"

# Frontmatter completeness and route cross-referencing
# Check each skill has name, description, model_hint
# Check each model_hint has a matching [[model_routes]] in config
# Check each skill name appears in IDENTITY.md routing table
```

## Owner context

Jiri — Rust developer interested in Bitcoin/Lightning ecosystem and micro-SaaS. The agent helps find buildable BTC showcase projects and AI-resistant SaaS opportunities.
