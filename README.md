# Amaano BookVerse Mobile App

Flutter user-facing client for the **BookVerse PHP REST API**. This project is separate from the PHP web admin panel in `htdocs/bookverse`.

## Stack

- **Flutter / Dart** — mobile UI
- **SQLite (`sqflite`)** — local offline cache only
- **PHP API + MySQL** — online source of truth (AwardSpace hosting)

## API base URL

Production base URL in `lib/core/constants/api_constants.dart`:

```
http://amaanobookverse.atwebpages.com/api/
```

Public asset base (covers, posters): `http://amaanobookverse.atwebpages.com`

## Run

```bash
flutter clean
flutter pub get
flutter run
```

## Screens (phase 1)

Splash → Login / Register → Verify code → Onboarding tokens → Home → Books → Details → Cart → Checkout

Library, purchases, notifications, and profile are included as user screens (not admin).
