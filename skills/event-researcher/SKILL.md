---
name: event-researcher
description: Research event speakers, sponsors, organizations, and thematic context on the web. Use when you need to investigate who is behind an event, what an organization does, or what the topic of an event is about.
---

# Event Researcher

Researches people, organizations, and topics related to events via web search and web fetch.

## Capabilities

- **Speaker bios**: Find professional profiles, LinkedIn, previous talks
- **Organization research**: Mission, programs, people, reach
- **Event theme context**: Related events, publications, news
- **Sponsor background**: Who sponsors the event, what do they do
- **Venue information**: Background on the venue, previous events held there

## How to research

### 1. Identify research targets
From the event info, list the entities to research:
- Speaker names
- Organization names
- Venue name
- Sponsor names

### 2. Web search per entity
```bash
# Speaker research
web_search: "[Speaker Name] biography OR LinkedIn OR profile"
web_search: "[Speaker Name] [organization] talk OR conference"

# Organization research
web_search: "[Org name] mission programs impact"
web_search: "[Org name] events OR conferences OR activities"

# Theme research
web_search: "[Event theme] research OR latest developments OR experts"
```

### 3. Web fetch for depth
For relevant pages found in search results:
```
web_fetch: <url> — extract key information
```

### 4. Compile findings
Organize findings per entity with:
- Name and role
- Key background (1-2 sentences)
- Relevance to the event
- Links to profiles/sources

## Output format

```
### Research Findings

#### Speakers
- **[Name]**: [role/org] — [2-3 sentence bio with key achievements]
  Sources: [links]

#### Organization
- **[Org name]**: [mission/purpose] — [scope, reach, programs]
  Sources: [links]

#### Event Theme
- [Contextual information about the theme/topic]
  Sources: [links]
```

## When to use

- After event-parser has extracted basic event info
- User asks "who is behind this event?", "what is this organization?"
- User wants a comprehensive briefing on an event and its context

## Tips

- Prioritize authoritative sources (official org sites, LinkedIn, Wikipedia)
- Cross-reference information from multiple sources
- Note any red flags or concerns (controversies, cancellations)
- Save relevant URLs for the final report
