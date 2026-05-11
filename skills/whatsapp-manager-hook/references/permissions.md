# Permission Key

Complete list of available permissions.

| Permission | Description |
|------------|-------------|
| `calendar.read_availability` | Check if Manuel has free time in calendar |
| `calendar.read_events` | Read full event details from calendar |
| `calendar.create_event` | Create events on Manuel's calendar |
| `calendar.modify_event` | Modify existing calendar events |
| `calendar.delete_event` | Delete calendar events |
| `contacts.read` | Read Manuel's contacts |
| `contacts.modify` | Add or modify contacts |
| `gmail.read` | Read emails (NEVER send without gmail.send) |
| `gmail.send` | Send emails on Manuel's behalf |
| `message.forward_to_manuel` | Forward messages to Manuel for review |
| `message.send_direct` | Send WhatsApp messages to Manuel on contact's behalf |
| `web.search` | Perform web searches |
| `ai.request` | Ask AI to generate content (drafts, summaries, etc.) |
| `reminder.create` | Create reminders for Manuel |

---

## Default Behavior Per Contact Type

| Contact Type | Default Permissions |
|--------------|-------------------|
| `admin` (Manuel) | ALL permissions — no confirmation needed |
| `known` | ZERO permissions — nothing allowed, everything requires explicit admin approval |
| `unknown` | ZERO permissions — everything requires approval |

---

## How to Grant Permissions

When Manuel approves a permission via WhatsApp:

1. Add the permission to the contact's entry in `references/contacts.md`
2. Optionally add context/limitations in the permission line
3. Execute the action

Example entry after granting:
```markdown
- **Permissions:**
  - calendar.read_availability — for scheduling family events only
  - web.search — PENDING (needs approval for first use)
```