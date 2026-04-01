---
name: outlook-mail-readonly
description: Read, search, and manage Outlook/Hotmail email via Microsoft Graph API without sending capability. Read emails, mark as read, create drafts, list folders. Use when the user wants to check, organize, or draft email on Outlook/Hotmail without being able to send. Triggered by requests like "read my outlook emails", "check hotmail", "show my inbox", "mark as read outlook", "create draft outlook".
---

# Outlook Mail Readonly

Read and manage Outlook/Hotmail emails — no sending. Uses Microsoft Graph API with OAuth2 device code flow.

## Quick Start

```bash
# Login (one-time setup — see references/setup.md for Azure app registration)
export OUTLOOK_CLIENT_ID=<your-client-id>
outlook-auth.sh login

# Check status
outlook-auth.sh status

# Read emails
outlook-mail.sh inbox           # List inbox (10 most recent)
outlook-mail.sh inbox 20        # List 20 most recent
outlook-mail.sh read <id>       # Read full email
outlook-mail.sh search "query"  # Search by subject/body
outlook-mail.sh from <email>    # Filter by sender

# Mark as read
outlook-mail.sh mark-read <id>
outlook-mail.sh mark-unread <id>

# Drafts
outlook-mail.sh draft-list              # List drafts
outlook-mail.sh draft-create "Subject" "Body text" [to@example.com]

# Folders & Stats
outlook-mail.sh folders   # List all folders
outlook-mail.sh stats     # Inbox totals
```

## Workflows

### Read and Mark as Read

```bash
# 1. List inbox
outlook-mail.sh inbox

# Example output:
# ✅ 1. [AAMkAGQ5NzE4Y...] 2026-03-31 09:00 | sender@outlook.com | Meeting tomorrow
# 📩 2. [AAMkAGQ5NzE4Y...] 2026-03-31 08:30 | newsletter@brand.com | Weekly update

# 2. Read one
outlook-mail.sh read AAMkAGQ5NzE4YjQ3LTQxYzgtNTNmZi1hZTBjLTZhZGM0MWIyMzJlNQ

# 3. Mark as read (use the full ID from the inbox command)
outlook-mail.sh mark-read AAMkAGQ5NzE4YjQ3LTQxYzgtNTNmZi1hZTBjLTZhZGM0MWIyMzJlNQ
```

### Create a Draft

```bash
# Draft without recipient (save to drafts only)
outlook-mail.sh draft-create "Meeting notes" "Notes from today's session"

# Draft with recipient (also saved to drafts, can be sent later via Outlook)
outlook-mail.sh draft-create "Follow up" "Hi, wanted to follow up on..." contact@example.com
```

### Search and Filter

```bash
outlook-mail.sh search "linkedin"          # Subject or body contains "linkedin"
outlook-mail.sh from "newsletter@brand.com"  # Emails from specific sender
outlook-mail.sh unread 5                    # 5 most recent unread
```

## Token Management

```bash
outlook-auth.sh status    # Check if logged in
outlook-auth.sh refresh    # Force refresh token
outlook-auth.sh logout     # Clear credentials
```

Tokens are stored in `~/.outlook-mail/` (configurable via `OUTLOOK_CONFIG_DIR`).

## Scripts

| Script | What it does |
|--------|-------------|
| `outlook-auth.sh` | OAuth login, token refresh, logout |
| `outlook-mail.sh` | All mail operations |

## Permissions

This skill only requests (and only works with):
- `Mail.Read` — Read emails
- `Mail.ReadWrite` — Mark read + create drafts
- `offline_access` — Keep logged in
- `User.Read` — Get email address

**No `Mail.Send` permission is requested or used.**

## Setup

See `references/setup.md` for step-by-step Azure app registration.

## Email IDs

Emails are identified by their full Microsoft Graph message ID (long string). When listing emails, the first 20 characters are shown in brackets as a preview — always use the **full ID** from the list output for `read`, `mark-read`, `mark-unread` operations.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OUTLOOK_CLIENT_ID` | Yes | Azure app client ID |
| `OUTLOOK_CLIENT_SECRET` | No | Azure app secret (optional for device flow) |
| `OUTLOOK_CONFIG_DIR` | No | Token storage dir (default `~/.outlook-mail`) |
| `OUTLOOK_TENANT` | No | `consumers` for personal accounts (default) |

## Limitations

- **Cannot send emails** — no `Mail.Send` permission
- **Cannot delete or move emails** — no `Mail.ReadWrite` delete scope
- **Cannot access shared mailboxes** — only the authenticated personal account
- Tokens expire ~1 hour; `offline_access` enables automatic refresh
