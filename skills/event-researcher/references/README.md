# Event Researcher — Notes

This skill uses OpenClaw's built-in `web_search` and `web_fetch` tools. No external API keys required.

## Capabilities

| Task | Tool | Notes |
|------|------|-------|
| Search speakers/orgs | `web_search` | Built-in Brave Search |
| Get detailed info | `web_fetch` | Fetches and extracts page content |
| Validate sources | `web_fetch` on specific URLs | Always cross-reference |

## Rate limits

- Brave Search has rate limits on free tier
- For heavy research, add delays between searches
- Always prioritize official sources (org websites, LinkedIn, Wikipedia)
