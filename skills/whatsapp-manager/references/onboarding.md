# WhatsApp Manager — Setup

This page explains how to configure this skill for a new OpenClaw agent.

## Step 1 — Add the SOUL.md Rule

Add the following block to the agent's `SOUL.md` file. This ensures the agent always checks contacts before responding to any WhatsApp message:

```markdown
## WhatsApp Contacts

Before responding to any WhatsApp message, always:
1. Read `contacts.md` to identify the sender
2. Apply their permission tier before taking any action
3. For new contacts: follow the onboarding workflow before engaging

Never execute Tier 2 or Tier 3 actions without explicit admin confirmation.
```

## Step 2 — Create contacts.md

```bash
cp contacts.example.md contacts.md
```

## Step 3 — Admin Setup (First Run)

When the skill is first activated, the agent should ask the person setting up OpenClaw to identify themselves as the admin. The agent asks for:

1. **Admin's name** — how the agent should address them
2. **Phone number** — must match the number connected to OpenClaw WhatsApp
3. **Email** — for contact purposes
4. **Preferred tone and language** — informal/formal, which languages
5. **Any relevant notes** — context the agent should know

The admin's phone number is the primary identifier. Any message from that number is treated as the admin. No separate validation step needed — the admin is whoever sets up OpenClaw.

## Step 4 — Restart OpenClaw

After configuring the skill and adding the SOUL.md rule:

```bash
openclaw gateway restart
```

## File Structure

```
whatsapp-manager/
├── SKILL.md                   ← skill definition
├── contacts.example.md        ← template (copy and fill in)
├── contacts.md                ← actual registry (create from example)
└── references/
    └── onboarding.md        ← this file
```

## Troubleshooting

**"I don't recognize this contact" for the admin**
→ Check that `contacts.md` exists and the admin entry has the correct phone number (international format: `+34...`)

**New contacts not being flagged**
→ Verify the SOUL.md rule is present and restart the gateway after adding it
