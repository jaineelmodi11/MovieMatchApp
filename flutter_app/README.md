# MovieMatch — Flutter client (iOS + Android)

A cross-platform rebuild of MovieMatch with a bold, modern UI, sharing the same [MovieMatch backend](../movie-backend) (Express + Flask ML + PostgreSQL). One Dart codebase runs on **both iOS and Android**.

## Features
- Tinder-style swipe deck (`flutter_card_swiper`) with like/pass buttons
- Recommendations screen with a **Content / Collaborative / Hybrid** engine switch
- Watchlist of your liked movies
- Lightweight onboarding (creates/restores a backend user; no Firebase required)
- Bold dark theme with gradient brand accents (Poppins via `google_fonts`)

## Run it

This folder ships the Dart source. Generate the iOS/Android platform shells once, then run:

```bash
cd flutter_app
flutter create .            # scaffolds android/ and ios/ around the existing lib/
flutter pub get

# point the app at your backend (see ../docs/RUNNING.md to start it)
flutter run --dart-define=BACKEND_URL=http://localhost:3000      # iOS simulator
flutter run --dart-define=BACKEND_URL=http://10.0.2.2:3000       # Android emulator
```

> The default `BACKEND_URL` is `http://localhost:3000`. On the Android emulator the host machine is reachable at `10.0.2.2`.

## Structure
```
lib/
  main.dart              app entry + session gate
  theme/app_theme.dart   colors, gradients, typography
  models/                Movie, SwipeMovie, Genre
  services/              ApiService (HTTP), Session (prefs)
  screens/               onboarding, swipe, recommendations, watchlist, profile
  widgets/               poster image, movie tile, swipe card
test/                    model parsing tests
```

## Tests
```bash
flutter test
```
