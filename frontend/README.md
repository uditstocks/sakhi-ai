# Sakhi AI

Voice-first agricultural assistant for rural women farmers in India — mobile-first Flutter UI with FastAPI-ready HTTP layer.

## Run the app

```bash
cd C:\Users\ASUS\Projects\sakhi_ai
flutter pub get
flutter run
```

For a physical device pointing at your machine's FastAPI server:

```bash
flutter run --dart-define=SAKHI_API_URL=http://192.168.1.10:8000
```

Android emulator → host machine:

```bash
flutter run --dart-define=SAKHI_API_URL=http://10.0.2.2:8000
```

## FastAPI backend (expected routes)

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/health` | Connectivity check |
| POST | `/api/v1/voice/query` | Voice / transcript query |
| GET | `/api/v1/mandi/prices` | Mandi prices (`crop`, `state`, `district`) |
| POST | `/api/v1/crop/diagnose` | Crop disease help |
| GET | `/api/v1/schemes` | Government schemes from DB — `{ "schemes": [{ "id", "name", "summary", "state", "eligibility" }] }` |
| POST | `/api/v1/sos` | SOS alert (`latitude`, `longitude`) |
| GET | `/api/v1/sync/status` | Returns `{ "last_sync_ago": "2 mins ago" }` |

Client: `lib/services/sakhi_api_service.dart` — inject `SakhiApiService(baseUrl: '...')` or use `ApiConfig.baseUrl`.

## Project structure

- `lib/screens/home_screen.dart` — main home UI and state
- `lib/widgets/` — mic pulse, waveform, cards, nav, background
- `lib/l10n/` — Hindi / English / Marathi strings
- `lib/services/` — API config + HTTP client

## Design

- Background `#2D5016`, accent `#F5C842`, fonts Poppins + Hind via Google Fonts
- Min touch targets 48px, high contrast, emoji-forward navigation
