---
name: location-intel
description: Get location intelligence for event venues. Geocode addresses, get directions, find nearby places (cafés, restaurants, parking). Use when you need travel options, venue coordinates, or nearby amenities for an event location.
---

# Location Intel

Provides location intelligence for event venues using Google Maps API.

## Capabilities

- **Geocoding**: Convert address → coordinates
- **Directions**: Driving, transit, cycling, walking times
- **Nearby places**: Cafés, restaurants, parking, hotels near the venue
- **Place details**: Ratings, reviews, opening hours

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

Types: `cafe`, `restaurant`, `parking`, `hotel`, `atm`, `convenience_store`

### Place details + reviews

```bash
curl -s "https://maps.googleapis.com/maps/api/place/details/json?place_id=[id]&fields=name,rating,reviews,opening_hours&key=$GOOGLE_MAPS_API_KEY"
```

## Output format

```
### Venue Location
📍 [Full address]
🗺️ Coordinates: [lat], [lng]

### Getting There
🚇 Metro: [nearest station] ([walking time])
🚗 Driving: [estimated time] ([traffic condition])
🚶 Walking: [estimated time]
🚲 Bike: [estimated time]

### Nearby Places
☕ [Place 1] — [rating] ⭐ — [walking distance]
🍽️ [Place 2] — [rating] ⭐ — [walking distance]
```

## When to use

- After event-parser identifies a venue address
- User asks for "how to get there", "where to eat nearby", "is there parking"
- Generating a logistics section for an event report

## API enablement

Enable these in [Google Cloud Console](https://console.cloud.google.com):
- Geocoding API
- Directions API
- Places API (New)
