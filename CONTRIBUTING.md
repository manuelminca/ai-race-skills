# Contributing to ai-race-skills

Thank you for your interest in contributing! This document explains how to add a new skill to the monorepo.

## What is a skill?

A skill is a folder in `skills/` containing:

```
skills/my-new-skill/
├── SKILL.md          ← required
├── references/        ← optional
│   └── setup.md      ← step-by-step setup instructions
├── scripts/          ← optional (CLI wrappers, helpers)
└── assets/          ← optional (templates, examples)
```

The only required file is `SKILL.md`.

## Adding a new skill

### 1. Create the skill folder

```bash
mkdir -p skills/my-new-skill/references
```

### 2. Write `SKILL.md`

Use the template at `SKILL_TEMPLATE.md`. The `description` field in the frontmatter is critical — it is what triggers OpenClaw to use your skill.

### 3. Write `references/setup.md`

If the skill requires any setup (API keys, CLI installation, credentials), document it step-by-step here.

### 4. Validate the skill

```bash
./setup/validate-all.sh
```

This runs `package_skill.py` on every skill in the repo. All skills must pass before merging.

### 5. Add tests (recommended)

If your skill has CLI scripts, add example commands to `SKILL.md` and test them manually.

## Skill quality standards

- **No credentials in code** — never commit tokens, API keys, or secrets
- **Environment variables for config** — use `skills.entries.<skill>.env` or `.env`
- **Language** — English only in SKILL.md and documentation
- **One skill per folder** — each skill is standalone
- **Dependencies documented** — if a skill needs a CLI tool, say so in setup.md

## Skill description guide

The `description` in SKILL.md frontmatter is the activation trigger. Be specific:

✅ Good:
```
Read and manage Outlook/Hotmail email via Microsoft Graph API. Use when the user wants to check, organize, or draft email on Outlook/Hotmail without being able to send.
```

❌ Bad:
```
Manages email.
```

## Updating existing skills

- Changes to SKILL.md trigger a CI validation run
- Update `references/setup.md` if the setup process changes
- If you change script paths, update all references in SKILL.md

## CI/CD

Every PR runs `./setup/validate-all.sh`. If validation fails, the PR cannot be merged.

To run validation locally:
```bash
./setup/validate-all.sh
```
