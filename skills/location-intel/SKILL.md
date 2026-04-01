---
name: location-intel
description: General-purpose location intelligence. Geocode addresses, get directions, find nearby places, search for venues or businesses. Use when the user asks for help finding a place, getting somewhere, or finding businesses or venues near a location. Not limited to events — works for any location query.
---

# Location Intel

Provides location intelligence for any address or query using Google Maps API. General-purpose — use it whenever the user needs help with places, directions, or geographic information.

## Capabilities

- **Geocoding**: Convert address → coordinates
- **Directions**: Driving, transit, cycling, walking times
- **Nearby places**: Cafés, restaurants, parking, hotels, shops, etc.
- **Place search**: Find specific types of venues or businesses
- **Place details**: Ratings, reviews, opening hours, photos

## Setup

Requires `GOOGLE_MAPS_API_KEY` environment variable.

Set via `skills.entries.location-intel.env.GOOGLE_MAPS_API_KEY` in `openclaw.json`
or set the environment variable directly.

## How to use

### Geocode an address

```bash
curl -s "https://maps.googleapis.com/maps/api/geocode/json?address=[encoded address]&key=$GOOGLE_MAPS_API_KEY"
```

### Directions

```bash
curl -s "https://maps.googleapis.com/maps/api/directions/json?origin=[from]&destination=[to]&mode=transit&key=$GOOGLE_MAPS_API_KEY"
```

Modes: `driving`, `walking`, `bicycling`, `transit`

### Nearby places

```bash
curl -s "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=[lat,lng]&radius=500&type=cafe&key=$GOOGLE_MAPS_API_KEY"
```

Types: `cafe`, `restaurant`, `parking`, `hotel`, `atm`, `convenience_store`, `gym`, `hospital`, etc.

### Place search (free-form query)

```bash
curl -s "https://maps.googleapis.com/maps/api/place/textsearch/json?query=best coworking spaces in Barcelona&key=$GOOGLE_MAPS_API_KEY"
```

### Place details + reviews

```bash
curl -s "https://maps.googleapis.com/maps/api/place/details/json?place_id=[id]&fields=name,rating,reviews,opening_hours,photos&key=$GOOGLE_MAPS_API_KEY"
```

## Output format

```
### Location
📍 [Full address]
🗺️ Coordinates: [lat], [lng]

### Getting There
🚇 Metro: [nearest station] ([walking time])
🚗 Driving: [estimated time]
🚶 Walking: [estimated time]

### Nearby Places
☕ [Place 1] — [rating] ⭐ — [walking distance]
🍽️ [Place 2] — [rating] ⭐ — [walking distance]
```

## When to use

- User asks "where is X?", "how do I get there?", "what's near Y?"
- User wants to find a specific type of place (café, coworking, parking)
- User needs directions or travel options
- Generating a logistics section for an event report

## API enablement

Enable these in [Google Cloud Console](https://console.cloud.google.com):
- Geocoding API
- Directions API
- Places API (New)
- Places Search API
