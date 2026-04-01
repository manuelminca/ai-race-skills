# Calendar Manager — Setup

This skill requires a calendar API to be configured. This page documents the Google Calendar (gog) setup.

## Option 1 — Google Calendar via gog CLI

### 1. Install gog

**macOS:**
```bash
brew install gog
```

**Linux:**
```bash
# Download from releases
curl -fsSL https://github.com/steipete/gogcli/releases/latest/download/gog-linux-amd64 -o gog
chmod +x gog
sudo mv gog /usr/local/bin/
```

### 2. Register a Google OAuth app

1. Go to [console.cloud.google.com](https://console.cloud.google.com) → **APIs & Services → Credentials**
2. Create an **OAuth 2.0 Client ID** (Desktop app or Web application)
3. Download the JSON client secrets file

### 3. Authenticate gog

```bash
# Register your client
gog auth credentials /path/to/client_secret.json

# Add your account
gog auth add your@gmail.com --services calendar
```

### 4. Set environment variables

```bash
# In your shell profile (.bashrc, .zshrc, etc.)
export GOG_ACCOUNT="your@gmail.com"
export GOG_KEYRING_PASSWORD="your_keyring_password"
```

Or add to `~/.openclaw/.env`:
```
GOG_ACCOUNT=your@gmail.com
GOG_KEYRING_PASSWORD=your_keyring_password
```

### 5. Test

```bash
gog calendar list --days 7
```

## Option 2 — Microsoft Outlook via Microsoft Graph

See the `outlook-email` skill for Microsoft Graph setup. Once configured, calendar operations via Graph API use the same authentication.

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GOG_ACCOUNT` | Yes | Default Google account for calendar operations |
| `GOG_KEYRING_PASSWORD` | Yes | Keyring passphrase for gog's encrypted token storage |
| `OUTLOOK_CLIENT_ID` | For Outlook | Azure app client ID (if using Microsoft Graph) |

## Troubleshooting

**"No credentials found"**
→ Run `gog auth credentials <path-to-client-secret>` and `gog auth add <email>`

**"Keyring locked"**
→ Set `GOG_KEYRING_PASSWORD` to unlock the keyring

**Token expired**
→ Run `gog auth add <email> --services calendar` again to re-authenticate
