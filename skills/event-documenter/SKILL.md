---
name: event-documenter
description: Generate structured reports from event research data. Compile findings from event-parser, event-researcher, and location-intel into clean, professional documents. Use when you have collected all the pieces of an event briefing and need to compile them into a readable report for the client.
---

# Event Documenter

Compiles all research findings into a structured, professional event report. This skill is independent from calendar management — it focuses purely on documentation.

**Recommended workflow:** Generate the report → share with client → only trigger calendar-manager if the client approves attending.

## Input (from other skills)

The report should integrate data from:

1. **event-parser**: Basic event info (name, date, venue, speakers, registration)
2. **event-researcher**: Speaker bios, organization context, theme analysis
3. **location-intel**: Venue details, travel options, nearby places

## Report Template

```markdown
# [Event Name]

**Date:** [date and time]
**Venue:** [venue name, full address]
**Organizers:** [organizer names]
**Registration:** [link if available]

---

## Summary
[2-3 sentence summary of what the event is about and why it matters]

## Event Details
- **Schedule:** [full agenda if available]
- **Speakers:** [list with roles and affiliations]
- **Topics:** [main themes and sessions]

## Speakers
- **[Name]** ([role/org]) — [relevant background and why they're notable for this event]

## Organization
- **[Org name]**: [mission and what they do]
- [Additional organizational context]

## Location & Logistics
- **Venue:** [name, address, neighborhood]
- **Getting there:** [transport options: metro, bus, driving, walking time]
- **Nearby:** [cafés, restaurants, hotels if relevant]

## Research Sources
- [List of key sources used in research]

## Notes
[Any additional observations, concerns, or recommendations]

---

*Report generated on [date]*
```

## Report Delivery

After generating the report:
1. Share the report with the client
2. Ask if they want to attend
3. If yes → use **calendar-manager** to check conflicts and create the event
4. If needs more info → continue researching

## When to use

- After running event-parser, event-researcher, and location-intel
- User asks for a "complete briefing", "full report", or "summary" of an event
- All research pieces are collected and need to be compiled
- Client needs a document to decide whether to attend

## Style Guidelines

- Professional but readable tone
- Prioritize actionable information
- Use bullet points for lists, prose for context
- Include source links for verification
- Flag any uncertainties clearly (e.g., "time not confirmed — verify with organizer")
- Write in English
