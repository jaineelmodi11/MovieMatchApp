-- MovieMatch schema. Auto-loaded by Postgres on first container start.

CREATE TABLE IF NOT EXISTS users (
    id            SERIAL PRIMARY KEY,
    firebase_uid  TEXT UNIQUE NOT NULL,
    display_name  TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS swipes (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    movie_id    INTEGER NOT NULL,
    direction   TEXT    NOT NULL CHECK (direction IN ('like', 'pass')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_swipes_user  ON swipes (user_id);
CREATE INDEX IF NOT EXISTS idx_swipes_movie ON swipes (movie_id);
