---
name: event-research-coordinator
description: Orchestrates the full event research workflow. Use when user wants to research an event, generate a report, or coordinate event discovery. Coordinates event-parser, event-researcher, location-intel, calendar-manager, and outlook-email.
---

# Event Research Coordinator

Orchestrates all event-research sub-skills to go from an event image/flyer/document to a complete event report with research, logistics, and calendar scheduling.

## Workflow

**Step 1 — Parse input**
If input is an image/document/URL → use **event-parser** to extract basic info.
If input is already text → skip to Step 2.

**Step 2 — Research**
Use **event-researcher** to investigate speakers, sponsors, organization, theme.

**Step 3 — Location intelligence**
Use **location-intel** to get venue coordinates, directions, nearby places.

**Step 4 — Generate report**
Use **event-documenter** to compile everything into a structured report.

**Step 5 — Deliver to client**
Share the report with the client. Ask if they want to attend.

**Step 6 — Calendar (only if client approves)**
If the client wants to attend → use **calendar-manager** to check conflicts and create the event.

## Workflow

### Step 1 — Parse the input
If the input is an image, document, or URL:
- Use **event-parser** to extract: event name, date/time, venue, speakers, organizers, registration link
- If the input is already text, skip to Step 2

### Step 2 — Research
- Use **event-researcher** to investigate: speaker bios, sponsor background, event theme, related events

### Step 3 — Location intelligence
- Use **location-intel** to get: venue coordinates, travel options, nearby cafés/restaurants

### Step 4 — Calendar check
- Use **calendar-manager** to check for scheduling conflicts and optionally create a calendar event

### Step 5 — Email check (optional)
- Use **outlook-email** to check inbox for related event proposals or confirmations

### Step 6 — Generate report
- Use **event-documenter** to compile all findings into a structured report

## Report structure

```
## [Event Name]
**Date:** ...
**Venue:** ...
**Speakers:** ...

### Summary
...

### Speakers
...

### Location
...

### Logistics
...

### Calendar
...
```

## When to use

- User says "investigate this event", "research this flyer", "what is this event about"
- User shares an image or PDF of an event
- User asks for a complete event briefing

## When NOT to use

- User only wants one specific sub-task (use the sub-skill directly instead)
- User asks about calendar only (use calendar-manager)
- User asks about email only (use outlook-email)
