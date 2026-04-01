---
name: event-parser
description: Extract structured event information from images, PDFs, or documents. Use when the user shares a flyer, poster, screenshot, PDF, or document related to an event and wants to extract its details.
---

# Event Parser

Extracts structured event information from various document formats.

## Capabilities

- **Images** (jpg, png, gif, webp): Use the `image` tool for flyer/poster analysis
- **PDFs**: Extract text using `exec` with `pdftotext` or Python
- **PPTX**: Extract text from slides using `unzip` + XML parsing
- **Plain text**: Parse directly

## What to extract

For each event, try to extract:

- **Event name** (required)
- **Date and time**
- **Venue / location** (full address)
- **Speakers** (names and titles)
- **Organizers / sponsors**
- **Registration link / URL
- **Description / abstract
- **Ticket price** (if mentioned)

## How to use

### Images
```
Use the image tool to analyze the flyer/image and extract event details.
```

### PDFs
```bash
pdftotext document.pdf - | head -200
# or
python3 -c "
import subprocess
result = subprocess.run(['pdftotext', 'document.pdf', '-'], capture_output=True, text=True)
print(result.stdout[:5000])
"
```

### PPTX
```bash
unzip -p presentation.pptx ppt/slides/slide*.xml | grep -oP '(?<=<a:t>)[^<]+' | head -200
```

## Output format

Return a structured summary:

```
Event: [name]
Date: [date and time]
Venue: [venue, city, address]
Speakers: [list with titles if available]
Organizers: [names]
Registration: [URL if available]
Description: [2-3 sentence summary]
```

## When to use

- User shares an image of an event flyer
- User uploads a PDF or PPTX with event information
- User asks "what event is this?" about a document

## Limitations

- Handwritten text may not be accurately recognized
- Complex layouts may miss some information
- Always verify critical details (exact time, address) manually if unsure
