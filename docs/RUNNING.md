# Running MovieMatch locally

The whole backend (Postgres + Flask ML service + Express API) runs with one command via Docker.

## Prerequisites
- Docker + Docker Compose
- A [TMDB API key](https://www.themoviedb.org/settings/api)

## 1. Backend (Docker)

```bash
# fetch the fine-tuned MiniLM model (git submodule)
git submodule update --init

# create your env file and fill in the two secrets
cp .env.example .env
#   TMDB_API_KEY   = your TMDB key
#   AI_SERVICE_KEY = any shared secret (API <-> ML use it to authenticate)
#   PG_PASSWORD    = any local DB password

# build + run everything
docker compose up --build
```

Services:
| Service | URL | Notes |
|---------|-----|-------|
| Express API | http://localhost:3000 | what the iOS app talks to |
| Flask ML    | http://localhost:5001 | embeddings / recommendations |
| Postgres    | localhost:5432 | schema auto-created from `db/init.sql` |

Quick check:
```bash
curl http://localhost:3000/movies | head
```

> First build pulls PyTorch + Sentence-Transformers, so the `ml` image takes a few minutes the first time.

## 2. iOS app

Open `MovieMatch.xcodeproj` in Xcode and run on the simulator.

- By default the app talks to `http://127.0.0.1:3000` (matches the Docker API).
- To point at a deployed backend instead, change the **`BackendBaseURL`** value in `MovieMatch/Info.plist` — no code changes needed.
- You'll also need your own `GoogleService-Info.plist` (Firebase) in `MovieMatch/` (gitignored).

## Without Docker
Run each piece manually: `psql -f db/init.sql`, then `python movie-backend/service.py`, then `node movie-backend/server.js` (all read config from `movie-backend/.env`).
