#!/bin/bash
# outlook-auth.sh — OAuth device code flow + token management for Microsoft Graph
# Stores tokens in ~/.outlook-mail/

CONFIG_DIR="${OUTLOOK_CONFIG_DIR:-$HOME/.outlook-mail}"
mkdir -p "$CONFIG_DIR"

CLIENT_ID="${OUTLOOK_CLIENT_ID:-}"
CLIENT_SECRET="${OUTLOOK_CLIENT_SECRET:-}"
TENANT="${OUTLOOK_TENANT:-consumers}"  # consumers = personal Microsoft accounts

usage() {
    echo "Usage: outlook-auth.sh <command>"
    echo ""
    echo "Commands:"
    echo "  login          Start OAuth device code flow (interactive)"
    echo "  status         Check if we have a valid token"
    echo "  get            Print current access token"
    echo "  refresh        Force refresh the access token"
    echo "  logout         Clear stored tokens"
    echo ""
    echo "Environment variables:"
    echo "  OUTLOOK_CLIENT_ID     Azure app client ID (required)"
    echo "  OUTLOOK_CLIENT_SECRET Azure app client secret (optional for device flow)"
    echo "  OUTLOOK_TENANT        'consumers' for personal accounts (default)"
    echo "  OUTLOOK_CONFIG_DIR    Override config directory (default ~/.outlook-mail)"
    exit 1
}

get_token() {
    local config="$CONFIG_DIR/tokens.json"
    if [ -f "$config" ]; then
        local exp=$(python3 -c "import json,sys; d=json.load(open('$config')); print(d.get('expires_on',0))" 2>/dev/null || echo 0)
        local now=$(date +%s)
        if [ "$exp" -gt "$((now + 60))" ]; then
            python3 -c "import json; print(json.load(open('$config'))['access_token'])"
            return 0
        fi
    fi
    return 1
}

cmd_status() {
    if get_token > /dev/null 2>&1; then
        echo "✅ Token available and valid"
        local email=$(python3 -c "import json; print(json.load(open('$CONFIG_DIR/tokens.json')).get('account',{}).get('username','?'))" 2>/dev/null || echo "?")
        echo "   Account: $email"
        local exp=$(python3 -c "import json,sys; d=json.load(open('$CONFIG_DIR/tokens.json')); from datetime import datetime; print(datetime.fromtimestamp(d.get('expires_on',0)).strftime('%Y-%m-%d %H:%M:%S'))" 2>/dev/null || echo "?")
        echo "   Expires: $exp"
    else
        echo "❌ No valid token found"
        echo "   Run: outlook-auth.sh login"
    fi
}

cmd_login() {
    if [ -z "$CLIENT_ID" ]; then
        echo "❌ OUTLOOK_CLIENT_ID not set"
        echo ""
        echo "Register an app at: https://portal.azure.com → App registrations"
        echo "  - Name: outlook-mail-poc"
        echo "  - Account type: Personal Microsoft accounts only"
        echo "  - Redirect URI: http://localhost:8080/callback"
        echo "  - Required permissions: Mail.Read, Mail.ReadWrite, offline_access"
        echo ""
        echo "Then run: OUTLOOK_CLIENT_ID=<your-client-id> outlook-auth.sh login"
        exit 1
    fi

    echo "🔐 Microsoft OAuth Device Code Flow"
    echo ""

    # Step 1: Request device code
    local device_data=$(curl -s -X POST \
        "https://login.microsoftonline.com/$TENANT/oauth2/v2.0/devicecode" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "client_id=$CLIENT_ID&scope=Mail.Read%20Mail.ReadWrite%20offline_access%20User.Read")

    local user_code=$(echo "$device_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('user_code',''))" 2>/dev/null)
    local device_code=$(echo "$device_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('device_code',''))" 2>/dev/null)
    local interval=$(echo "$device_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('interval',5))" 2>/dev/null)
    local verification_uri=$(echo "$device_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('verification_uri',''))" 2>/dev/null)

    if [ -z "$device_code" ]; then
        echo "❌ Failed to get device code:"
        echo "$device_data"
        exit 1
    fi

    echo "1. Open: $verification_uri"
    echo "2. Enter code: $user_code"
    echo ""
    echo "⏳ Waiting for authentication... (press Ctrl+C to cancel)"

    # Step 2: Poll for token
    local token_data=""
    local attempts=0
    while [ $attempts -lt 120 ]; do
        sleep "$interval"
        token_data=$(curl -s -X POST \
            "https://login.microsoftonline.com/$TENANT/oauth2/v2.0/token" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
            -d "client_id=$CLIENT_ID" \
            -d "device_code=$device_code")

        local error=$(echo "$token_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('error',''))" 2>/dev/null)

        if [ "$error" == "authorization_pending" ]; then
            echo -n "."
        elif [ "$error" == "authorization_declined" ]; then
            echo ""
            echo "❌ Authorization declined by user"
            exit 1
        elif [ -n "$error" ]; then
            echo ""
            echo "❌ Auth error: $error"
            echo "$token_data"
            exit 1
        else
            break
        fi
        attempts=$((attempts + 1))
    done
    echo ""

    if [ -z "$token_data" ]; then
        echo "❌ Token request timed out"
        exit 1
    fi

    # Save token
    echo "$token_data" | python3 -c "
import json, sys, os
d = json.load(sys.stdin)
config_dir = os.environ.get('OUTLOOK_CONFIG_DIR', os.path.expanduser('~/.outlook-mail'))
os.makedirs(config_dir, exist_ok=True)
result = {
    'access_token': d['access_token'],
    'refresh_token': d.get('refresh_token',''),
    'expires_on': int(__import__('time').time()) + d.get('expires_in', 3600),
    'token_type': d.get('token_type', 'Bearer'),
    'account': d.get('account', {})
}
with open(os.path.join(config_dir, 'tokens.json'), 'w') as f:
    json.dump(result, f, indent=2)

client_id = os.environ.get('OUTLOOK_CLIENT_ID', '')
with open(os.path.join(config_dir, 'config.json'), 'w') as f:
    json.dump({'client_id': client_id}, f)
print('✅ Token saved')
"

    # Get user info
    local access_token=$(echo "$token_data" | python3 -c "import json,sys; print(json.load(sys.stdin)['access_token'])")
    local user_info=$(curl -s -X GET "https://graph.microsoft.com/v1.0/me" -H "Authorization: Bearer $access_token")
    local email=$(echo "$user_info" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('mail', d.get('userPrincipalName','?')))" 2>/dev/null || echo "?")
    echo ""
    echo "✅ Logged in as: $email"
}

cmd_get() {
    if get_token; then
        :
    else
        echo "❌ No valid token"
        exit 1
    fi
}

cmd_refresh() {
    local config="$CONFIG_DIR/tokens.json"
    if [ ! -f "$config" ]; then
        echo "❌ No token file found. Run login first."
        exit 1
    fi

    if [ -z "$CLIENT_ID" ]; then
        CLIENT_ID=$(python3 -c "import json; print(json.load(open('$CONFIG_DIR/config.json')).get('client_id',''))" 2>/dev/null || echo "")
    fi

    if [ -z "$CLIENT_ID" ]; then
        echo "❌ OUTLOOK_CLIENT_ID required to refresh"
        exit 1
    fi

    local refresh_token=$(python3 -c "import json; print(json.load(open('$config')).get('refresh_token',''))" 2>/dev/null)

    if [ -z "$refresh_token" ]; then
        echo "❌ No refresh token found. Run login again."
        exit 1
    fi

    echo "🔄 Refreshing token..."
    local token_data=$(curl -s -X POST \
        "https://login.microsoftonline.com/$TENANT/oauth2/v2.0/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=refresh_token" \
        -d "client_id=$CLIENT_ID" \
        -d "refresh_token=$refresh_token")

    if echo "$token_data" | python3 -c "import json,sys; d=json.load(sys.stdin); sys.exit(1 if 'error' in d else 0)" 2>/dev/null; then
        echo "$token_data" | python3 -c "
import json, sys, os
d = json.load(sys.stdin)
config_dir = os.environ.get('OUTLOOK_CONFIG_DIR', os.path.expanduser('~/.outlook-mail'))
result = {
    'access_token': d['access_token'],
    'refresh_token': d.get('refresh_token',''),
    'expires_on': d.get('expires_on', int(__import__('time').time()) + d.get('expires_in', 3600)),
    'token_type': d.get('token_type', 'Bearer'),
    'account': {}
}
with open(os.path.join(config_dir, 'tokens.json'), 'w') as f:
    json.dump(result, f, indent=2)
print('✅ Token refreshed')
"
    else
        local error=$(echo "$token_data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('error_description', d.get('error','')))" 2>/dev/null)
        echo "❌ Refresh failed: $error"
        echo "   Run: outlook-auth.sh login"
        exit 1
    fi
}

cmd_logout() {
    rm -f "$CONFIG_DIR/tokens.json" "$CONFIG_DIR/config.json"
    echo "✅ Logged out"
}

# Main
COMMAND="${1:-}"
case "$COMMAND" in
    login)   cmd_login ;;
    status)  cmd_status ;;
    get)     cmd_get ;;
    refresh) cmd_refresh ;;
    logout)  cmd_logout ;;
    *)       usage ;;
esac
