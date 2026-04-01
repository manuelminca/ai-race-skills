# Event Research Coordinator — Notes

This is an orchestrator skill — it delegates to other skills in sequence. It has no external dependencies.

## No setup required

This skill works out of the box once all sub-skills are installed. Install the sub-skills you need:
- `event-parser` — always needed (to parse input)
- `event-researcher` — for research phase
- `location-intel` — for logistics
- `event-documenter` — always needed (to generate report)
- `calendar-manager` — only if calendar integration is desired
- `outlook-email` — only if email integration is desired

## Sub-skills

See each skill's own `references/setup.md` for their specific setup requirements.
