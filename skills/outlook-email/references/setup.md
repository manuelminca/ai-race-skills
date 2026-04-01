# Setup — Outlook Mail Readonly Skill

## Prerequisites

- `curl`
- `python3`
- A Microsoft Azure account (free)

## Step 1 — Register Azure App

1. Go to [portal.azure.com](https://portal.azure.com) → **App registrations** → **New registration**
2. Name: `outlook-mail-readonly`
3. Account type: **Personal Microsoft accounts only** (Hotmail, Live, Outlook.com)
4. Redirect URI: `http://localhost:8080/callback`
5. Click **Register**
6. Copy the **Application (client) ID** — you'll need it for `OUTLOOK_CLIENT_ID`

## Step 2 — Configure API Permissions

In your app's left menu → **API permissions** → **Add a permission**:

Find **Microsoft Graph** → **Delegated permissions** and add:
- `Mail.Read` — Read emails
- `Mail.ReadWrite` — Mark as read + create drafts
- `offline_access` — Keep you logged in (refresh tokens)
- `User.Read` — Get your email address

Click **Grant admin consent** if available (may not be needed for personal accounts).

## Step 3 — Optional: Create Client Secret

For device code flow, a client secret is **not required**. However, if you want to use the client credentials flow later:

In **Certificates & secrets** → **New client secret** → copy the value as `OUTLOOK_CLIENT_SECRET`.

## Step 4 — Set Environment Variables

Add to your environment or `.env` file:

```bash
OUTLOOK_CLIENT_ID=<your-client-id>   # From Step 1
OUTLOOK_CLIENT_SECRET=<secret>        # Optional (Step 3)
OUTLOOK_CONFIG_DIR=~/.outlook-mail    # Where tokens are stored
PATH="$PATH:$HOME/.outlook-mail"      # So scripts are accessible
```

## Step 5 — Login

```bash
export OUTLOOK_CLIENT_ID=<your-client-id>
outlook-auth.sh login
```

Follow the prompts — it will give you a code to enter at `https://microsoft.com/devicelogin`.

## Step 6 — Test

```bash
outlook-auth.sh status    # Should show ✅ Token available
outlook-mail.sh inbox     # Should show your inbox
```

## File Locations

- `~/.outlook-mail/tokens.json` — OAuth access + refresh tokens (keep private)
- `~/.outlook-mail/config.json` — Client ID

## Troubleshooting

| Error | Solution |
|-------|----------|
| `OUTLOOK_CLIENT_ID not set` | Export the variable before running login |
| `invalid_grant` | Refresh token expired — run `outlook-auth.sh login` again |
| `Insufficient privileges` | Check Azure app has the right permissions granted |
| Token expired | Run `outlook-auth.sh refresh` or `outlook-auth.sh login` |
