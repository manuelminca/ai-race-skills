# Event Parser — Notes

This skill uses OpenClaw's built-in tools (image analysis, exec for PDF/PPTX extraction) and does not require external API keys or credentials.

## Capabilities

| Input type | Tool used | Notes |
|------------|-----------|-------|
| Images (jpg, png) | `image` tool | Built-in vision model |
| PDFs | `exec` with `pdftotext` | Requires `poppler-utils` on Linux |
| PPTX | `exec` with `unzip` | Built-in on most systems |
| URLs | `web_fetch` | Built-in |
| Plain text | Direct parsing | Built-in |

## Installing dependencies

### pdftotext (Linux)
```bash
# Debian/Ubuntu
sudo apt install poppler-utils

# macOS
brew install poppler
```
