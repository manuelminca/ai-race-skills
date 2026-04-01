# Event Documenter — Notes

This skill is purely prompt-based — it compiles information from other skills into a structured report. No external APIs or credentials required.

## How it works

The skill takes the outputs from:
- `event-parser` → basic event info
- `event-researcher` → research findings
- `location-intel` → logistics

And assembles them into a markdown report following the template in `SKILL.md`.

## No setup required

This skill works out of the box with no API keys, credentials, or CLI tools.
