#!/bin/bash
# outlook-mail.sh — Read, mark-read, and draft emails via Microsoft Graph API
# Requires: curl, python3, jq (optional)
# Token from: outlook-auth.sh login

set -e

CONFIG_DIR="${OUTLOOK_CONFIG_DIR:-$HOME/.outlook-mail}"
TOKEN_FILE="$CONFIG_DIR/tokens.json"
GRAPH_BASE="https://graph.microsoft.com/v1.0"

get_token() {
    if [ ! -f "$TOKEN_FILE" ]; then
        echo "❌ Not logged in. Run: outlook-auth.sh login" >&2
        exit 1
    fi
    local exp=$(python3 -c "import json,sys; d=json.load(open('$TOKEN_FILE')); print(d.get('expires_on',0))" 2>/dev/null || echo 0)
    local now=$(date +%s)
    if [ "$exp" -gt "$((now + 60))" ]; then
        python3 -c "import json; print(json.load(open('$TOKEN_FILE'))['access_token'])"
        return 0
    fi
    # Try refresh
    echo "🔄 Token expired, refreshing..." >&2
    outlook-auth.sh refresh > /dev/null 2>&1 || {
        echo "❌ Token refresh failed. Run: outlook-auth.sh login" >&2
        exit 1
    }
    python3 -c "import json; print(json.load(open('$TOKEN_FILE'))['access_token'])"
}

api_get() {
    local token=$(get_token)
    curl -s -X GET "$GRAPH_BASE$1" \
        -H "Authorization: Bearer $token" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json"
}

api_patch() {
    local token=$(get_token)
    curl -s -X PATCH "$GRAPH_BASE$1" \
        -H "Authorization: Bearer $token" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$2"
}

api_post() {
    local token=$(get_token)
    curl -s -X POST "$GRAPH_BASE$1" \
        -H "Authorization: Bearer $token" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$2"
}

html_to_text() {
    python3 -c "
import sys, html
text = sys.stdin.read()
# Remove HTML tags
import re
text = re.sub(r'<br\s*/?>', '\n', text)
text = re.sub(r'</p>', '\n\n', text)
text = re.sub(r'</div>', '\n', text)
text = re.sub(r'<[^>]+>', '', text)
text = html.unescape(text)
text = re.sub(r'\n{3,}', '\n\n', text)
print(text.strip())
"
}

usage() {
    echo "outlook-mail.sh <command> [args]"
    echo ""
    echo "Mail commands:"
    echo "  inbox [n]                List latest n inbox emails (default 10, max 50)"
    echo "  unread [n]               List latest n unread emails (default 10)"
    echo "  search <query> [n]       Search emails by subject/from/body"
    echo "  from <email> [n]         List emails from a specific sender"
    echo "  read <id>                Read full email content"
    echo "  draft-list [n]           List draft emails (default 10)"
    echo "  draft-create <subj> <body> [to]  Create a draft email"
    echo "  mark-read <id>           Mark email as read"
    echo "  mark-unread <id>         Mark email as unread"
    echo "  folders                  List all mail folders"
    echo "  stats                    Show inbox statistics"
    echo ""
    echo "Examples:"
    echo "  outlook-mail.sh inbox 20"
    echo "  outlook-mail.sh search \"from:linkedin.com\""
    echo "  outlook-mail.sh read AAMkAGQ5..."
    echo "  outlook-mail.sh mark-read AAMkAGQ5..."
    echo "  outlook-mail.sh draft-create \"My draft\" \"Hello world\""
    exit 1
}

cmd_inbox() {
    local count="${1:-10}"
    count=$((count > 50 ? 50 : count))
    local data=$(api_get "/me/mailFolders/inbox/messages?\$top=$count&\$select=id,subject,from,receivedDateTime,isRead,bodyPreview&\$orderby=receivedDateTime%20desc")
    echo "$data" | python3 -c "
import json, sys
d = json.load(sys.stdin)
msgs = d.get('value', [])
if not msgs:
    print('(no messages)')
for i, m in enumerate(msgs, 1):
    read = '✅' if m.get('isRead') else '📩'
    sender = m.get('from', {}).get('emailAddress', {}).get('address', '?')
    date = m.get('receivedDateTime', '')[:16].replace('T', ' ')
    subject = m.get('subject', '(no subject)')
    print(f\"{read} {i}. [{m['id'][:20]}...] {date} | {sender} | {subject}\")
"
}

cmd_unread() {
    local count="${1:-10}"
    count=$((count > 50 ? 50 : count))
    local data=$(api_get "/me/mailFolders/inbox/messages?\$top=$count&\$select=id,subject,from,receivedDateTime,isRead,bodyPreview&\$filter=isRead%20eq%20false&\$orderby=receivedDateTime%20desc")
    echo "$data" | python3 -c "
import json, sys
d = json.load(sys.stdin)
msgs = d.get('value', [])
if not msgs:
    print('(no unread messages)')
for i, m in enumerate(msgs, 1):
    sender = m.get('from', {}).get('emailAddress', {}).get('address', '?')
    date = m.get('receivedDateTime', '')[:16].replace('T', ' ')
    subject = m.get('subject', '(no subject)')
    print(f\"📩 {i}. [{m['id'][:20]}...] {date} | {sender} | {subject}\")
"
}

cmd_search() {
    local query="$1"
    local count="${2:-10}"
    count=$((count > 50 ? 50 : count))
    if [ -z "$query" ]; then
        echo "❌ Search query required"
        exit 1
    fi
    local encoded_query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")
    local data=$(api_get "/me/mailFolders/inbox/messages?\$top=$count&\$select=id,subject,from,receivedDateTime,isRead,bodyPreview&\$filter=contains(subject,'$query')%20or%20contains(bodyPreview,'$query')&\$orderby=receivedDateTime%20desc")
    echo "$data" | python3 -c "
import json, sys
d = json.load(sys.stdin)
msgs = d.get('value', [])
if not msgs:
    print(f'(no results for: $query)')
for i, m in enumerate(msgs, 1):
    read = '✅' if m.get('isRead') else '📩'
    sender = m.get('from', {}).get('emailAddress', {}).get('address', '?')
    date = m.get('receivedDateTime', '')[:16].replace('T', ' ')
    subject = m.get('subject', '(no subject)')
    print(f\"{read} {i}. [{m['id'][:20]}...] {date} | {sender} | {subject}\")
"
}

cmd_from() {
    local sender="$1"
    local count="${2:-10}"
    count=$((count > 50 ? 50 : count))
    if [ -z "$sender" ]; then
        echo "❌ Sender email required"
        exit 1
    fi
    local encoded_sender=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$sender'))")
    local data=$(api_get "/me/mailFolders/inbox/messages?\$top=$count&\$select=id,subject,from,receivedDateTime,isRead,bodyPreview&\$filter=from/emailAddress/address%20eq%20'$encoded_sender'&\$orderby=receivedDateTime%20desc")
    echo "$data" | python3 -c "
import json, sys
d = json.load(sys.stdin)
msgs = d.get('value', [])
if not msgs:
    print(f'(no emails from: $sender)')
for i, m in enumerate(msgs, 1):
    read = '✅' if m.get('isRead') else '📩'
    date = m.get('receivedDateTime', '')[:16].replace('T', ' ')
    subject = m.get('subject', '(no subject)')
    print(f\"{read} {i}. [{m['id'][:20]}...] {date} | {subject}\")
"
}

cmd_read() {
    local msg_id="$1"
    if [ -z "$msg_id" ]; then
        echo "❌ Message ID required"
        exit 1
    fi
    local data=$(api_get "/me/messages/$msg_id")
    echo "$data" | python3 -c "
import json, sys, re
d = json.load(sys.stdin)
if 'error' in d:
    print(f\"❌ Error: {d['error'].get('message', 'Unknown')}\")
    sys.exit(1)
subject = d.get('subject', '(no subject)')
sender = d.get('from', {}).get('emailAddress', {})
to_list = d.get('toRecipients', [])
date = d.get('receivedDateTime', '')[:19].replace('T', ' ')
body = d.get('body', {})
body_content = body.get('content', '')
if body.get('contentType', '') == 'html':
    # Convert HTML to text
    import html
    text = re.sub(r'<br\s*/?>', '\n', body_content)
    text = re.sub(r'</p>', '\n\n', text)
    text = re.sub(r'<[^>]+>', '', text)
    text = html.unescape(text)
    text = re.sub(r'\n{3,}', '\n\n', text).strip()
else:
    text = body_content.strip()
print(f\"Subject: {subject}\")
print(f\"From: {sender.get('name', '')} <{sender.get('address', '')}>\")
print(f\"To: {', '.join([r['emailAddress']['address'] for r in to_list])}\")
print(f\"Date: {date}\")
print(f\"Read: {'Yes' if d.get('isRead') else 'No'}\")
print()
print(text)
"
}

cmd_draft_list() {
    local count="${1:-10}"
    count=$((count > 50 ? 50 : count))
    local data=$(api_get "/me/mailFolders/drafts/messages?\$top=$count&\$select=id,subject,toRecipients,createdDateTime,bodyPreview&\$orderby=createdDateTime%20desc")
    echo "$data" | python3 -c "
import json, sys
d = json.load(sys.stdin)
msgs = d.get('value', [])
if not msgs:
    print('(no drafts)')
for i, m in enumerate(msgs, 1):
    date = m.get('createdDateTime', '')[:16].replace('T', ' ')
    subject = m.get('subject', '(no subject)')
    to = ', '.join([r['emailAddress']['address'] for r in m.get('toRecipients', [])]) or '(no recipients)'
    preview = m.get('bodyPreview', '')[:60]
    print(f\"📝 {i}. [{m['id'][:20]}...] {date}\")
    print(f\"   To: {to}\")
    print(f\"   Subject: {subject}\")
    if preview:
        print(f\"   Preview: {preview}\")
"
}

cmd_draft_create() {
    local subject="$1"
    local body="$2"
    local to="$3"
    if [ -z "$subject" ] || [ -z "$body" ]; then
        echo "❌ Usage: outlook-mail.sh draft-create <subject> <body> [to]"
        exit 1
    fi
    # Build request body using python
    local body_json
    body_json=$(python3 -c "
import json, sys
subj = '''$subject'''
bdy = '''$body'''
rec = json.dumps([{'emailAddress': {'address': '$to'}}]) if '$to' else '[]'
print(json.dumps({
    'subject': subj,
    'body': {'contentType': 'text', 'content': bdy},
    'toRecipients': json.loads(rec)
}))
")
    local data=$(api_post "/me/messages" "$body_json")
    echo "$data" | python3 -c "
import json, sys
d = json.load(sys.stdin)
if 'error' in d:
    print(f\"❌ Error: {d['error'].get('message', 'Unknown')}\")
    sys.exit(1)
print(f\"✅ Draft created: [{d.get('id','')[:20]}...]\")
print(f\"   Subject: {d.get('subject','')}\")
print(f\"   Created: {d.get('createdDateTime','')[:16].replace('T',' ')}\")
"
}

cmd_mark_read() {
    local msg_id="$1"
    if [ -z "$msg_id" ]; then
        echo "❌ Message ID required"
        exit 1
    fi
    local data=$(api_patch "/me/messages/$msg_id" '{"isRead": true}')
    if echo "$data" | python3 -c "import json,sys; d=json.load(sys.stdin); sys.exit(1 if 'error' in d else 0)" 2>/dev/null; then
        echo "✅ Marked as read: [$msg_id]"
    else
        local error=$(echo "$data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('error',{}).get('message', d.get('error','')))")
        echo "❌ Error: $error"
        exit 1
    fi
}

cmd_mark_unread() {
    local msg_id="$1"
    if [ -z "$msg_id" ]; then
        echo "❌ Message ID required"
        exit 1
    fi
    local data=$(api_patch "/me/messages/$msg_id" '{"isRead": false}')
    if echo "$data" | python3 -c "import json,sys; d=json.load(sys.stdin); sys.exit(1 if 'error' in d else 0)" 2>/dev/null; then
        echo "✅ Marked as unread: [$msg_id]"
    else
        local error=$(echo "$data" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('error',{}).get('message', d.get('error','')))")
        echo "❌ Error: $error"
        exit 1
    fi
}

cmd_folders() {
    local data=$(api_get "/me/mailFolders?\$select=id,displayName,totalItemCount,unreadItemCount&\$orderby=displayName")
    echo "$data" | python3 -c "
import json, sys
d = json.load(sys.stdin)
folders = d.get('value', [])
for f in folders:
    unread = f.get('unreadItemCount', 0)
    total = f.get('totalItemCount', 0)
    name = f.get('displayName', '?')
    icon = '📁' if unread == 0 else '📬'
    print(f'{icon} {name} | {total} total | {unread} unread')
"
}

cmd_stats() {
    local data=$(api_get "/me/mailFolders/inbox?\$select=totalItemCount,unreadItemCount")
    echo "$data" | python3 -c "
import json, sys
d = json.load(sys.stdin)
if 'error' in d:
    print(f\"❌ Error: {d['error'].get('message', 'Unknown')}\")
else:
    print(f\"📬 Inbox: {d.get('totalItemCount',0)} total | {d.get('unreadItemCount',0)} unread\")
"
}

# Main
COMMAND="${1:-}"
shift || true
case "$COMMAND" in
    inbox)       cmd_inbox "$@" ;;
    unread)      cmd_unread "$@" ;;
    search)      cmd_search "$@" ;;
    from)        cmd_from "$@" ;;
    read)        cmd_read "$@" ;;
    draft-list)  cmd_draft_list "$@" ;;
    draft-create) cmd_draft_create "$@" ;;
    mark-read)   cmd_mark_read "$@" ;;
    mark-unread) cmd_mark_unread "$@" ;;
    folders)     cmd_folders ;;
    stats)       cmd_stats ;;
    *)           usage ;;
esac
