# Location Intel — Setup

## 1. Get a Google Maps API key

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a new project (or select existing)
3. Go to **APIs & Services → Library**
4. Enable these APIs:
   - **Geocoding API**
   - **Directions API**
   - **Places API (New)**
5. Go to **APIs & Services → Credentials**
6. Click **Create Credentials → API Key**
7. Copy the generated key

## 2. Restrict the API key (recommended)

In the credentials page, click on your API key and set restrictions:

- **Application restrictions**: None or HTTP referrers (recommended: set to your domain)
- **API restrictions**: Geocoding API, Directions API, Places API (New)

## 3. Set the environment variable

```bash
# In your shell profile
export GOOGLE_MAPS_API_KEY="AIzaSy..."

# Or add to ~/.openclaw/.env
GOOGLE_MAPS_API_KEY=AIzaSy...
```

## 4. Test

```bash
curl -s "https://maps.googleapis.com/maps/api/geocode/json?address=Barcelona&key=$GOOGLE_MAPS_API_KEY" | head -20
```

## Cost

Google Maps API has a free tier:
- **Geocoding**: 40,000 requests/month free
- **Places**: 28,000 requests/month free
- **Directions**: 40,000 requests/month free

Beyond that, pay-as-you-go pricing applies. Set a budget alert in GCP to avoid surprises.

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GOOGLE_MAPS_API_KEY` | Yes | Your Google Maps API key |

## Troubleshooting

**"This API project is not authorized"**
→ Enable the required APIs in Google Cloud Console for your project

**"REQUEST_DENIED"**
→ Check that your API key has the correct API restrictions

**High cost**
→ Enable API key restrictions and set up budget alerts in GCP
