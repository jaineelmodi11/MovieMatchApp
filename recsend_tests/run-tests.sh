#!/usr/bin/env bash
# Contract tests for the MovieMatch API, powered by the recsend CLI.
set -e
cd "$(dirname "$0")"

# DB-only test that runs anywhere (no TMDB/ML keys required)
recsend send -f users.yaml

# The following also require the ML service + a TMDB key and a seeded user,
# so run them against a fully configured stack:
#   recsend send -f swipes.yaml
#   recsend send -f content_recs.yaml

echo "✅ recsend contract tests passed"
