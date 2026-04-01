---
name: event-documenter
description: Generate structured event reports from data collected by event-parser, event-researcher, and location-intel. Use when you have all the pieces of an event briefing and need to compile them into a clean, readable report.
---

# Event Documenter

Compiles all research findings into a structured, professional event report.

## Input (what to expect from previous steps)

The event report should integrate:

1. **From event-parser**: Basic event info (name, date, venue, speakers, registration)
2. **From event-researcher**: Speaker bios, organization context, theme analysis
3. **From location-intel**: Venue details, travel options, nearby places
4. **From calendar-manager**: Scheduling status (confirmed, conflict, event created)
5. **From outlook-email**: Any relevant email correspondence about the event

## Report template

```markdown
# [Event Name]

**Date:** [date and time]
**Venue:** [venue name, full address]
**Organizers:** [organizer names]
**Registration:** [link if available]

---

## Resumen
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

## Calendar Status
- [ ] Checked for conflicts
- [ ] Event created in calendar (if confirmed)

## Research Sources
- [List of key sources used in research]

## Notes
[Any additional observations, concerns, or recommendations]
```

## When to use

- After running event-parser, event-researcher, and location-intel
- User asks for a "complete briefing", "full report", or "summary" of an event
- All research pieces are collected and need to be compiled

## Style guidelines

- Professional but readable tone
- Prioritize actionable information
- Use bullet points for lists, prose for context
- Include source links for verification
- Flag any uncertainties clearly (e.g., "time not confirmed — verify with organizer")
