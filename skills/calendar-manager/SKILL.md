---
name: calendar-manager
description: Manage Google Calendar events via gog CLI. Create events, list upcoming events, check for scheduling conflicts. Use when the user wants to add something to their calendar, check their availability, or manage calendar events. General-purpose calendar capability for any agent task.
---

# Calendar Manager

Manages Google Calendar using the `gog` CLI tool.

## Setup

Requires `gog` CLI installed and authenticated:

```bash
# Install (macOS)
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 2>/dev/null
brew install gog

# Authenticate
gog auth credentials /path/to/client_secret.json
gog auth add your@email.com --services calendar
```

Required environment variables:
- `GOG_ACCOUNT`: default Google account to use
- `GOG_KEYRING_PASSWORD`: keyring passphrase (set in `~/.openclaw/.env`)

## Commands

```bash
# List upcoming events
gog calendar list --days 7

# Create an event
gog calendar event create \
  --title "Event Name" \
  --start "2026-04-15T19:00:00" \
  --end "2026-04-15T21:00:00" \
  --location "Venue Name, Address" \
  --description "Description" \
  --account your@gmail.com

# Check for conflicts
gog calendar list --days 0 --start "2026-04-15T19:00:00" --end "2026-04-15T21:00:00"
```

## For event research workflow

After confirming an event is worth attending:

1. **Check conflicts** before creating:
```bash
gog calendar list --days 0 --start "[event-date]T[event-time]"
```

2. **Create the event** if free:
```bash
gog calendar event create \
  --title "[Event Name]" \
  --start "[date]T[time]:00" \
  --end "[date]T[time+duration]:00" \
  --location "[venue]" \
  --description "Organizers: [org]\nRegistration: [link]"
```

## When to use

- After event-researcher confirms event details
- User asks "am I free on [date]?", "add this to my calendar"
- Checking scheduling conflicts before committing to an event

## Limitations

- Only works with the Google account configured in `GOG_ACCOUNT`
- Cannot access shared calendars (personal account only)
- Requires gog to be installed and authenticated on the host/sandbox
