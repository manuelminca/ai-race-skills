# WhatsApp Manager — Setup

This page explains how to configure this skill for a new OpenClaw agent.

## Step 1 — Add the SOUL.md Rule

Add the following block to the agent's `SOUL.md` file:

```markdown
## WhatsApp Contacts

You manage WhatsApp on behalf of the admin. Your role is to act as the admin's communication and management layer — filtering, drafting, organizing, and executing tasks that the admin entrusts to you.

Before responding to any WhatsApp message, always:
1. Read `skills/whatsapp-manager/contacts.md` to identify the sender
2. Apply their permission tier before taking any action
3. For new contacts: follow the onboarding workflow before engaging

Never execute Tier 2 or Tier 3 actions without explicit admin confirmation.
When a contact reaches out, your goal is always to help the admin: gather information, draft responses, coordinate logistics, or flag relevant requests — not to hold extended conversations that should go to the admin directly.
```

## Step 2 — Create contacts.md

**Important:** `contacts.md` must be created **inside the skill directory**, not in the workspace root.

From your workspace root (e.g. `~/.openclaw/workspace-secretariat/`):

```bash
cp skills/whatsapp-manager/contacts.example.md skills/whatsapp-manager/contacts.md
```

Then edit `skills/whatsapp-manager/contacts.md` with the admin details.

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

## Correct File Structure

```
workspace/
├── SOUL.md                  ← add the WhatsApp Contacts rule here
└── skills/
    └── whatsapp-manager/
        ├── SKILL.md
        ├── contacts.example.md   ← template (do not edit)
        ├── contacts.md           ← create from example, fill in admin details
        └── references/
            └── onboarding.md
```

**Do NOT put `contacts.md` at the workspace root.** It must live inside `skills/whatsapp-manager/` alongside the skill files. This keeps the skill self-contained and portable.

## Troubleshooting

**"I don't recognize this contact" for the admin**
→ Check that `skills/whatsapp-manager/contacts.md` exists (not at workspace root) and the admin entry has the correct phone number (international format: `+34...`)

**New contacts not being flagged**
→ Verify the SOUL.md rule is present and restart the gateway after adding it
