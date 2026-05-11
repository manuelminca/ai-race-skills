# Setup: WhatsApp Manager Hook

Initial setup guide to get the skill running.

---

## 1. Contacts (contacts.md)

**Important:** `contacts.md` must live inside `references/`, inside the skill directory. This keeps the skill self-contained and portable.

From your workspace root, create `skills/whatsapp-manager-hook/references/contacts.md` with this format:

```markdown
# WhatsApp Contacts Registry

**Source of truth for contact permissions.**
**Default: NO permissions. Ask the admin before granting anything new.**

---

## [Your Name]

- **Phone:** +XXXXXXXXXXX
- **Email:** [your-email]
- **Position:** Owner / Administrator
- **Type:** admin
- **Tags:** [admin, owner]
- **Language:** en
- **Timezone:** [your-timezone]
- **Tone:** informal
- **Permissions:**
  - ALL — administrator, no confirmation needed for any action
- **Notes:** The admin. Can override any decision.
- **First seen:** YYYY-MM-DD

## [Contact Name]

- **Phone:** +34 600 000 000
- **Email:** [email or PENDING]
- **Position:** [Role/Company]
- **Relationship:** colleague|friend|family|unknown
- **Type:** known|unknown
- **Tags:** [relevant tags]
- **Language:** en
- **Timezone:** [timezone]
- **Tone:** informal|formal
- **Permissions:**
  - [permission]
  - [permission]
- **Notes:** [relevant notes]
- **First seen:** YYYY-MM-DD
```

---

## 2. SOUL.md — WhatsApp Rules

Add to workspace `SOUL.md`:

```markdown
## WhatsApp Rules

**Never pose as the admin. Always verify number of the person you are speaking with.**

### Before responding:
1. Read `skills/whatsapp-manager-hook/references/whatsapp-guide.md`
2. Identify sender by phone number in contacts.md
3. Act accordingly to their allowed permissions (specified in contacts.md per user)

### Before sending:
1. Correct recipient? (number in contacts.md)
2. Message for THIS person? (not contaminated from another conversation)
3. Do I have permission?
```

---

## 3. HEARTBEAT.md — Cross-Session Messaging

Update workspace `HEARTBEAT.md` to include pending_replays review:

```markdown
## WhatsApp Cross-Session Messaging (Pending Replays)

### Pending Replays Review

Every heartbeat (every 2 minutes):

1. Read `skills/whatsapp-manager-hook/references/pending-replays.md`
2. Find entries with `Status: pending`
3. For each entry:
   - Identify recipient (number/channel)
   - Replay exact message
   - If success → Update `Status: sent`
   - If fail → increment `Attempts`, update `Last attempt`
4. If `Attempts >= 3` → alert the admin

### Entry Format

```markdown
## 2026-04-10T06:27:00Z

- **From:** [Name] (+34600000000)
- **To:** [Name] (+34600000000)
- **Source session:** [session name]
- **Message:** [exact message content]
- **Status:** pending
- **Attempts:** 0
- **Last attempt:** -
```
```

---

## 4. Heartbeat Interval

Configure heartbeat to run every 2 minutes for cross-session messaging.

### Configuration Steps

1. Edit `~/.openclaw/openclaw.json`
2. Find the agent config (e.g., `id: "secretariat"`)
3. Change heartbeat interval from `"15m"` to `"2m"`
4. Validate JSON:
   ```bash
   jq . ~/.openclaw/openclaw.json > /dev/null
   ```
5. Restart the gateway:
   ```bash
   openclaw gateway restart
   ```

---

## 5. Archive Directory

Create the archive folder for sent replays history:

```bash
mkdir -p skills/whatsapp-manager-hook/archive
```

---

## 6. Verification Checklist

- [ ] `references/contacts.md` created with the admin
- [ ] `references/pending-replays.md` exists (empty is fine)
- [ ] `archive/` directory created
- [ ] SOUL.md updated with WhatsApp rules
- [ ] HEARTBEAT.md updated with replays review
- [ ] Heartbeat configured at 2 minutes

---

## Files Overview

```
whatsapp-manager-hook/
├── SKILL.md                    # Main skill instructions
├── setup.md                   # This file
├── plugin/
│   └── index.js               # Plugin hooks (before_prompt_build, message_sending)
└── references/
    ├── contacts.md            # Contact database (create from contacts.example.md)
    ├── contacts.example.md    # Template for contacts
    ├── pending-replays.md     # Cross-session pending messages
    ├── permissions.md         # Permission reference
    └── whatsapp-guide.md      # Quick reference for WhatsApp interactions
```

---

## Troubleshooting

### Heartbeat doesn't process pending_replays

1. Verify file exists at `references/pending-replays.md`
2. Verify HEARTBEAT.md includes the instructions
3. Check logs: `openclaw logs`

### Message stays as pending

1. Verify recipient phone number (must be in contacts.md)
2. Verify channel permissions
3. Manually check file format matches the expected structure

### Permission not working

1. Verify contact exists in `references/contacts.md`
2. Check permission is explicitly listed under their Permissions section
3. Remember: session context may be stale — always re-read the file

---

*Last updated: 2026-05-11*