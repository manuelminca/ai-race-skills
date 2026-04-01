---
name: calendar-manager
description: General-purpose calendar management for any agent. Create events, list upcoming events, check for scheduling conflicts, cancel events. Use when the user wants to add something to their calendar, check their availability, or manage calendar events. Works with any calendar API via the appropriate skill or CLI.
---

# Calendar Manager

A general-purpose calendar layer that helps agents interact with the user's calendar following consistent patterns and user preferences. It is agnostic to the underlying calendar provider (Google Calendar via gog, Outlook via Graph API, etc.).

## Setup

This skill is a **layer on top of your calendar API**. It requires a calendar CLI or API skill to be installed. See the official documentation for your provider:

- **Google Calendar (gog)**: See [clawhub.ai/steipete/gog](https://clawhub.ai/steipete/gog) for installation and authentication
- **Microsoft Graph (Outlook)**: See the `outlook-email` skill for Graph API setup

Required environment variables (gog example):
- `GOG_ACCOUNT`: default Google account
- `GOG_KEYRING_PASSWORD`: keyring passphrase

## Gathering User Preferences

Before creating calendar events, the agent should know the user's preferences:

- Whether the agent should **always ask for confirmation before creating events** (vs. creating autonomously)
- Preferred event title format
- Buffer time between events (e.g., 15 min travel)
- Default event duration
- Preferred reminder settings
- Any keywords to auto-decline (e.g., "unsubscribe", "newsletter")

Store these in `memory/YYYY-MM-DD.md` or the user's profile for future reference.

## Commands (gog example)

```bash
# List upcoming events
gog calendar list --days 7

# Check for conflicts
gog calendar list --days 0 --start "2026-04-15T19:00:00" --end "2026-04-15T21:00:00"

# Create an event
gog calendar event create \
  --title "[Event Name]" \
  --start "2026-04-15T19:00:00" \
  --end "2026-04-15T21:00:00" \
  --location "[Venue]" \
  --description "Organizers: [org]\nRegistration: [link]"
```

## Workflow for Creating Events

1. **Check conflicts** — list events for the target day
2. **Present options** — suggest time slot to user before creating
3. **Confirm with user** — get explicit approval before committing
4. **Create event** — add to calendar with clear title and description
5. **Confirm creation** — tell the user the event was added

## Event Title Format

Recommend a clear format: `[Event Name] — [Organizer or Topic]`
Example: "AI Conference 2026 — TechSummit Barcelona"

## When to use

- User says "add this to my calendar", "am I free on [date]?"
- User asks for a summary of their upcoming events
- User wants to cancel or modify a calendar event
- Coordinating schedules for meetings or events

## Limitations

- Only works with the calendar account configured in the underlying skill
- Cannot access shared calendars unless explicitly configured
- Requires the calendar CLI/API skill to be installed and authenticated
