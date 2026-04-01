# ai-race-skills

A collection of [OpenClaw](https://openclaw.ai) skills for event research, calendar management, location intelligence, and productivity.

> **Zero credentials in this repo.** All API keys and tokens are injected at runtime via environment variables. See [.env.example](.env.example).

## Skills

| Skill | Description |
|-------|-------------|
| [event-research-coordinator](skills/event-research-coordinator/) | Orchestrates the full event research workflow |
| [event-parser](skills/event-parser/) | Extract info from images, PDFs, PPTs, documents |
| [event-researcher](skills/event-researcher/) | Web research on speakers, sponsors, organizations |
| [event-documenter](skills/event-documenter/) | Generate structured event reports |
| [location-intel](skills/location-intel/) | Geocoding, directions, nearby places |
| [calendar-manager](skills/calendar-manager/) | Manage calendar events (Google Calendar, Outlook) |
| [outlook-email](skills/outlook-email/) | Read-only Outlook/Hotmail via Microsoft Graph |

## Prerequisites

- [OpenClaw](https://openclaw.ai) installed
- For skills requiring APIs: respective API keys and credentials (see each skill's `references/setup.md`)
- For calendar-manager: `gog` CLI for Google Calendar (see [clawhub.ai/steipete/gog](https://clawhub.ai/steipete/gog))

## Installing skills

### Option 1 — Symlink each skill to your workspace (recommended)

```bash
# Clone the repo anywhere you like
git clone https://github.com/manuelminca/ai-race-skills ~/ai-race-skills

# Symlink the skills you want to your OpenClaw workspace
ln -s ~/ai-race-skills/skills/event-research-coordinator \
  ~/.openclaw/workspace/my-agent/skills/event-research-coordinator

# Or for all skills at once:
for skill in ~/ai-race-skills/skills/*/; do
  ln -s "$skill" ~/.openclaw/workspace/my-agent/skills/$(basename "$skill")
done

# Restart OpenClaw
openclaw gateway restart
```

The symlink approach means:
- Skills stay up-to-date with `git pull`
- Each agent can choose which skills to use
- No modification to `openclaw.json` required

### Option 2 — extraDirs (share skills across all agents)

Add to `~/.openclaw/openclaw.json`:

```json
{
  "skills": {
    "load": {
      "extraDirs": ["/path/to/ai-race-skills/skills"]
    }
  }
}
```

Then restart the gateway. All skills in the directory become available to all agents.

## Configuring credentials

Each skill requires different credentials. Copy `.env.example` and fill in your values:

```bash
cp .env.example .env
# Edit .env with your API keys
```

Then load the variables in your shell or OpenClaw config:

```bash
# In your shell profile
set -a && source ~/.ai-race-skills/.env && set +a
```

Or add them directly to `~/.openclaw/.env`.

### Skill-specific credentials

| Skill | Required credentials |
|-------|---------------------|
| `calendar-manager` (Google) | `GOG_ACCOUNT` + `GOG_KEYRING_PASSWORD` |
| `calendar-manager` (Outlook) | `OUTLOOK_CLIENT_ID` |
| `outlook-email` | `OUTLOOK_CLIENT_ID` |
| `location-intel` | `GOOGLE_MAPS_API_KEY` |

See each skill's `references/setup.md` for full setup instructions.

## Validating skills

```bash
# Validate all skills
./setup/validate-all.sh

# Validate a specific skill
./setup/validate-all.sh skills/outlook-email
```

All skills are validated automatically on every PR and push via GitHub Actions.

## Updating skills

If you used symlinks:

```bash
cd ~/ai-race-skills
git pull
```

Skills update immediately — just restart OpenClaw if needed.

## Adding a new skill

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add a skill to the monorepo.

## CI/CD

Every PR runs `./setup/validate-all.sh` via GitHub Actions. All skills must pass validation before merging to `main`.

## Project structure

```
ai-race-skills/
├── README.md                    ← you are here
├── CONTRIBUTING.md               ← how to add new skills
├── SKILL_TEMPLATE.md            ← template for new skills
├── LICENSE
├── .gitignore
├── .env.example                 ← credential template
├── .github/workflows/
│   └── validate-skills.yml      ← CI validation
├── setup/
│   ├── validate-all.sh          ← validates all skills
│   ├── package_skill.py         ← skill validator
│   └── quick_validate.py
└── skills/
    ├── event-research-coordinator/
    ├── event-parser/
    ├── event-researcher/
    ├── event-documenter/
    ├── location-intel/
    ├── calendar-manager/
    └── outlook-email/
```

## License

MIT — use freely for any purpose.
