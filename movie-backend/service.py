# service.py

import os
import warnings
from flask import Flask, jsonify, request, abort
from flask_cors import CORS
import psycopg2
import pandas as pd
import requests
from dotenv import load_dotenv

# Hugging Face & ML imports
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

# ─── Load .env ───────────────────────────────────────────────────────────────
load_dotenv()
warnings.filterwarnings("ignore")

##### CONFIG #####
API_KEY          = os.getenv("AI_SERVICE_KEY")
AI_SERVICE_BASE  = os.getenv("AI_SERVICE_BASE")
TMDB_API_KEY     = os.getenv("TMDB_API_KEY", "6115b8e1b06596eabe2b34ca88f8b37b")
if not API_KEY or not AI_SERVICE_BASE:
    raise RuntimeError("Missing AI_SERVICE_BASE or AI_SERVICE_KEY in .env")

DB_PARAMS = {
    "host":     "localhost",
    "database": "movieswipe",
    "user":     "postgres",
    "password": "Gonkilla_11",
    "port":     5432
}
##################

# Initialize Flask
app = Flask(__name__)
CORS(app)

# Pre-load Transformer model
# Updated to use the SNLI/MNLI fine-tuned all-MiniLM-L6-v2
hf_model = SentenceTransformer('finetuned_embedding/fine_tuned_model')

# Auth guard
@app.before_request
def require_api_key():
    auth = request.headers.get("Authorization", "")
    if auth != f"Bearer {API_KEY}":
        abort(403)

# Postgres connection
conn = psycopg2.connect(**DB_PARAMS)

def load_swipes_df():
    df = pd.read_sql("SELECT user_id, movie_id, direction FROM swipes", conn)
    df["rating"] = df["direction"].map(lambda d: 1 if d == "like" else 0)
    return df

def fetch_tmdb_details(ids):
    """Fetch full TMDB details for a list of movie IDs; return DataFrame."""
    records = []
    for mid in ids:
        r = requests.get(
            f"https://api.themoviedb.org/3/movie/{mid}",
            params={"api_key": TMDB_API_KEY, "language": "en-US"}
        )
        if r.status_code == 200:
            data = r.json()
            records.append(data)
    return pd.DataFrame(records)

@app.route("/recommendations/content/<int:user_id>")
def recommend_content(user_id: int):
    print(f"[service] recommend_content called for user {user_id}")
    swipes    = load_swipes_df()
    liked_ids = swipes[(swipes.user_id == user_id) & (swipes.rating == 1)]["movie_id"].tolist()

    # If user has no likes, fallback to popular
    if not liked_ids:
        print(f"[service] no likes → returning popular fallback")
        pop = requests.get(
            "https://api.themoviedb.org/3/movie/popular",
            params={"api_key": TMDB_API_KEY, "language":"en-US","page":1}
        ).json()["results"]
        top_ids = [m["id"] for m in pop[:10]]
        return jsonify(fetch_tmdb_details(top_ids).to_dict(orient="records"))

    # Candidate pool: popular page 1
    pop = requests.get(
        "https://api.themoviedb.org/3/movie/popular",
        params={"api_key": TMDB_API_KEY, "language":"en-US","page":1}
    ).json()["results"]
    pop_df = pd.DataFrame(pop)[["id","overview"]].fillna({"overview": ""})

    # Embeddings
    overviews  = pop_df["overview"].tolist()
    embeddings = hf_model.encode(overviews, convert_to_numpy=True)

    # Build user vector
    liked_idxs = [i for i, mid in enumerate(pop_df["id"]) if mid in liked_ids]
    if not liked_idxs:
        print(f"[service] liked_ids not in popular pool → returning popular fallback")
        top_ids = [m["id"] for m in pop[:10]]
        return jsonify(fetch_tmdb_details(top_ids).to_dict(orient="records"))

    user_vec = embeddings[liked_idxs].mean(axis=0, keepdims=True)
    sims     = cosine_similarity(user_vec, embeddings)[0]

    # Rank & select top 10, excluding already liked
    ranked, rec_ids, seen = np.argsort(sims)[::-1], [], set(liked_ids)
    for idx in ranked:
        mid = int(pop_df.iloc[idx]["id"])
        if mid not in seen:
            rec_ids.append(mid)
            seen.add(mid)
        if len(rec_ids) >= 10:
            break

    return jsonify(fetch_tmdb_details(rec_ids).to_dict(orient="records"))

@app.route("/recommendations/cf/<int:user_id>")
def recommend_cf(user_id):
    print(f"[service] recommend_cf called for user {user_id}")
    from surprise import Dataset, Reader, KNNBasic

    swipes    = load_swipes_df()
    reader    = Reader(rating_scale=(0,1))
    data      = Dataset.load_from_df(swipes[["user_id","movie_id","rating"]], reader)
    trainset  = data.build_full_trainset()

    algo = KNNBasic(sim_options={"user_based": True})
    algo.fit(trainset)

    all_ids = swipes["movie_id"].unique()
    seen    = set(swipes[swipes.user_id==user_id]["movie_id"].tolist())

    preds = [(mid, algo.predict(user_id,mid).est) for mid in all_ids if mid not in seen]
    top_ids = [mid for mid,_ in sorted(preds, key=lambda x: x[1], reverse=True)[:10]]

    if not top_ids:
        return recommend_content(user_id)

    return jsonify(fetch_tmdb_details(top_ids).to_dict(orient="records"))

@app.route("/recommendations/hybrid/<int:user_id>")
def recommend_hybrid(user_id):
    print(f"[service] recommend_hybrid called for user {user_id}")
    cf_recs      = recommend_cf(user_id).json
    content_recs = recommend_content(user_id).json
    hybrid_ids   = [m["id"] for m in cf_recs[:5] + content_recs[:5]]
    return jsonify(fetch_tmdb_details(hybrid_ids).to_dict(orient="records"))

if __name__ == "__main__":
    import logging
    logging.getLogger('werkzeug').disabled = True
    app.logger.disabled = True

    port = int(os.getenv("PORT","5000"))
    app.run(port=port, debug=True, use_reloader=False)
