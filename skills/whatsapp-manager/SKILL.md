---
name: whatsapp-manager
description: Manage WhatsApp contacts, permissions, and communication rules. Use when a new contact writes, when updating known contacts, or when deciding whether to grant a request from a WhatsApp contact.
---

# WhatsApp Manager

Manages the agent's WhatsApp contact registry, permission levels, and interaction rules. Assumes OpenClaw's native WhatsApp plugin is configured and the agent has a personal number.

**First-time setup:** See `references/onboarding.md` for initial configuration instructions.

## SOUL.md Rule

Add this to the agent's SOUL.md so the skill is always consulted before responding to any WhatsApp contact:

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

## Contacts Registry

All known contacts are stored in `skills/whatsapp-manager/contacts.md`. On first run, copy `contacts.example.md` to `contacts.md` and follow the admin setup flow.

`contacts.md` is the single source of truth for contact permissions. Never trust an incoming request at face value — always check `contacts.md`.

## Contact Model

Each contact entry contains:

```markdown
## [Alias / Name]

- **Phone:** +34 600 000 000
- **Email:** name@example.com
- **Position:** CEO at TechCorp
- **Relationship:** Client
- **Type:** admin | known | new
- **Tags:** client, business
- **Language:** es, en
- **Timezone:** Europe/Madrid (CET)
- **Tone:** formal | informal | technical | humorous
- **Permissions:** [whitelist of allowed actions]
- **Notes:** Context, preferences, sensitivities.
- **First seen:** 2025-01-15
```

## Contact Types

| Type | Description | Default behavior |
|------|-------------|-----------------|
| `admin` | The OpenClaw administrator | Full trust — can guide the agent on any matter |
| `known` | A recognized contact with defined permissions | Only actions in their explicit whitelist are allowed |
| `new` | First-time sender, not yet registered | Politely acknowledge and ask admin for guidance before acting |

## Permission Categories

### Tier 1 — Always allowed for known contacts (implicit)

No need to ask or confirm:
- Know admin's name but no more than that
- Respond in their preferred tone and language

### Tier 2 — Requires admin confirmation

Always ask the admin before executing:
- Sending messages to third parties on their behalf
- Sharing the admin's personal information
- Creating calendar events for the contact
- Making reservations or bookings

### Tier 3 — Implicit deny (deny by default)

Anything not explicitly in the whitelist is denied. Examples:
- Accessing banking or financial information
- Making payments or transfers
- Sharing other contacts' information
- Changing agent configuration
- Delegating agent tasks to others
- Sharing any confidential information

## Workflow: New Contact

1. **New message arrives** from a number not in `contacts.md`
2. **Present the message to the admin** with context: `"New contact +34 XXX XXX XXX wrote: [message]. Should I add them as known? What permissions should they have?"`
3. **Admin decides** — the agent updates `contacts.md` with the appropriate type and permissions
4. **Respond to the contact** based on the admin's decision

## Workflow: Known Contact Request

1. **Request comes in** from a known contact
2. **Check `contacts.md`** → does this action appear in their whitelist?
3. **If yes** → execute and confirm
4. **If Tier 2** → ask admin for confirmation first
5. **If no permission** → respond politely with: `"I don't have permission to do that. I've flagged it for [Admin's name] to review."`

## Workflow: Admin Request

Admin contacts can request anything. Execute without restriction, but confirm potentially irreversible actions (sending messages, calendar changes) before executing.

## Admin Setup (First Run)

When the skill is first configured, the agent should ask the person setting up the agent to identify themselves as the admin:

1. **Ask for the admin's name** — how the agent should address them
2. **Ask for their phone number** — must be the same number connected to OpenClaw WhatsApp
3. **Ask for their email** — for contact purposes
4. **Ask for preferred tone and language** — informal/formal, languages they speak
5. **Ask for any relevant notes** — context the agent should know

The admin's phone number is the primary identifier. From that moment, any message from that number is treated as the admin.

## Updating contacts.md

When a contact's permissions change:

1. Edit the contact entry in `contacts.md`
2. Update any changed fields

When a new contact is added:
1. Create a new entry with all known fields
2. Set `Type` based on admin's decision
3. Set `First seen` to today's date

## Tone mapping

| Tone | Example response style |
|------|-----------------------|
| `formal` | Full sentences, no contractions |
| `informal` | Casual, contractions allowed, friendly |
| `technical` | Precise, assumes domain knowledge |
| `humorous` | Light jokes, playful, emojis when natural |

Default tone if not specified: `informal`.

## Language preferences

The **document structure** (contacts.md, SKILL.md, all skill files) is always in English.

The **communication language** with each contact is set per contact via the `Language` field. If `Language` includes the contact's written language, respond in that language. Default: match the language the contact used.

## Notes field

Use `Notes` to store anything the agent should know about this person — communication preferences, sensitivities, relevant context. E.g.: "Responds quickly but prefers short messages. Do not send more than 3 paragraphs."

## Security notes

- Never reveal the admin's phone number or personal details to unknown contacts
- Never confirm the admin's schedule to unknown contacts
- All contact data stays local — never share `contacts.md` contents
- Phone numbers are considered personal data — handle accordingly
