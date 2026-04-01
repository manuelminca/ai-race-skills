# ai-race-skills

Custom [OpenClaw](https://openclaw.ai) skills for event research, document processing, and productivity.

> **Zero credentials in this repo.** All API keys and tokens are injected at runtime via environment variables. See [.env.example](.env.example).

## Skills

| Skill | Description |
|-------|-------------|
| [event-research-coordinator](skills/event-research-coordinator/) | Orchestrates the full event research workflow |
| [event-parser](skills/event-parser/) | Extract info from images, PDFs, PPTs |
| [event-researcher](skills/event-researcher/) | Web research on speakers, sponsors, topics |
| [event-documenter](skills/event-documenter/) | Generate structured event reports |
| [location-intel](skills/location-intel/) | Maps, geocoding, nearby places |
| [calendar-manager](skills/calendar-manager/) | Google Calendar via gog CLI |
| [outlook-email](skills/outlook-email/) | Outlook/Hotmail read-only via Microsoft Graph |

## Installing skills

### Option 1 — Clone and symlink (recommended for local development)

```bash
# Clone the repo
git clone https://github.com/manuelminca/ai-race-skills ~/ai-race-skills

# Symlink individual skills to your workspace
ln -s ~/ai-race-skills/skills/event-research-coordinator \
  ~/.openclaw/workspace-ted/skills/event-research-coordinator

# Restart OpenClaw gateway
openclaw gateway restart
```

### Option 2 — extraDirs (share skills across all agents)

Add to `~/.openclaw/openclaw.json`:

```json
{
  "skills": {
    "load": {
      "extraDirs": ["/home/openclaw/ai-race-skills/skills"]
    }
  }
}
```

Then restart the gateway.

## Credentials

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

Each skill documents its required environment variables in its own `SKILL.md`.

## Validating skills

```bash
# Validate all skills
./setup/validate-all.sh

# Validate a specific skill
python3 ~/.npm-global/lib/node_modules/openclaw/skills/skill-creator/scripts/package_skill.py \
  skills/outlook-email
```

## CI/CD

Every PR runs `validate-all.sh` via GitHub Actions. All skills must pass validation before merging to `main`.

## License

MIT
