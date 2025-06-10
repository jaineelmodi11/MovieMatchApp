# training/test_retrieval.py

from pathlib import Path
import pandas as pd
import tensorflow as tf
import tensorflow_recommenders as tfrs
from tensorflow.keras.layers import StringLookup

# ─── Resolve paths ────────────────────────────────────────────────
ROOT        = Path(__file__).resolve().parent.parent
M           = ROOT / "models"
USER_MODEL  = M / "user_model"
MOVIE_MODEL = M / "movie_model"
CANDIDATES  = M / "candidates.csv"
USER_VOCAB  = M / "user_vocab.csv"
MOVIE_VOCAB = M / "movie_vocab.csv"

# ─── 1) Load vocabularies ────────────────────────────────────────
user_tokens  = pd.read_csv(USER_VOCAB )["token"].tolist()
movie_tokens = pd.read_csv(MOVIE_VOCAB)["token"].tolist()

user_lookup  = StringLookup(vocabulary=user_tokens, mask_token=None)
movie_lookup = StringLookup(vocabulary=movie_tokens, mask_token=None)

# ─── 2) Load the SavedModel towers ──────────────────────────────
user_model  = tf.keras.models.load_model(USER_MODEL,  compile=False)
movie_model = tf.keras.models.load_model(MOVIE_MODEL, compile=False)

# ─── 3) Precompute embeddings ──────────────────────────────────
cands       = pd.read_csv(CANDIDATES)["tmdbId"].astype(str).tolist()
ids_tensor  = tf.constant(cands)
embeddings  = movie_model(ids_tensor)

# ─── 4) Build & populate the BruteForce index ───────────────────
index = tfrs.layers.factorized_top_k.BruteForce(user_model)
ds    = tf.data.Dataset.from_tensor_slices((embeddings, ids_tensor)).batch(128)
index.index_from_dataset(ds)

# ─── 5) Smoke-test a query ───────────────────────────────────────
sample = "42"  # must be in user_vocab.csv
_, ids = index(tf.constant([sample]), k=5)
print(f"Top 5 for user {sample} →", [int(x) for x in ids[0].numpy()])
