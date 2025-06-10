# training/train_retrieval.py

from pathlib import Path
import zipfile
import pandas as pd
import tensorflow as tf
import tensorflow_recommenders as tfrs
from tensorflow.keras.layers import StringLookup

# ─── Paths ────────────────────────────────────────────────────────
BASE_DIR         = Path(__file__).resolve().parent
ZIP_PATH         = BASE_DIR / "ml-latest-small.zip"
MODELS_DIR       = BASE_DIR.parent / "models"
USER_MODEL_DIR   = MODELS_DIR / "user_model"
MOVIE_MODEL_DIR  = MODELS_DIR / "movie_model"
CANDIDATES_CSV   = MODELS_DIR / "candidates.csv"
USER_VOCAB_CSV   = MODELS_DIR / "user_vocab.csv"
MOVIE_VOCAB_CSV  = MODELS_DIR / "movie_vocab.csv"

# ─── 1) Load & prep data ─────────────────────────────────────────
with zipfile.ZipFile(ZIP_PATH) as zf:
    ratings = pd.read_csv(zf.open("ml-latest-small/ratings.csv"))
    links   = pd.read_csv(zf.open("ml-latest-small/links.csv"),
                          usecols=["movieId","tmdbId"])

df = (
    ratings
    .merge(links, on="movieId")
    .dropna(subset=["tmdbId"])
)
df["userId"]     = df["userId"].astype(int).astype(str)
df["tmdbId_str"] = df["tmdbId"].astype(int).astype(str)

# Ensure output dirs exist
MODELS_DIR.mkdir(parents=True, exist_ok=True)

# Save the candidate list
unique_ids = df["tmdbId_str"].unique()
pd.DataFrame({"tmdbId": unique_ids}).to_csv(CANDIDATES_CSV, index=False)

# ─── 2) Shuffle & split ──────────────────────────────────────────
df_shuf = df.sample(frac=1, random_state=42)
cut     = int(len(df_shuf) * 0.1)
val_df, train_df = df_shuf[:cut], df_shuf[cut:]

train_ds = (
    tf.data.Dataset
      .from_tensor_slices({
          "user_id":  train_df["userId"].values,
          "movie_id": train_df["tmdbId_str"].values
      })
      .shuffle(100_000, seed=42)
      .batch(8192)
      .cache()
)

val_ds = (
    tf.data.Dataset
      .from_tensor_slices({
          "user_id":  val_df["userId"].values,
          "movie_id": val_df["tmdbId_str"].values
      })
      .batch(8192)
      .cache()
)

# ─── 3) Build & persist vocabularies ─────────────────────────────
user_vocab  = StringLookup(mask_token=None)
movie_vocab = StringLookup(mask_token=None)
user_vocab.adapt(train_ds.map(lambda x: x["user_id"]))
movie_vocab.adapt(train_ds.map(lambda x: x["movie_id"]))

pd.DataFrame({"token": user_vocab.get_vocabulary()}) \
  .to_csv(USER_VOCAB_CSV, index=False)
pd.DataFrame({"token": movie_vocab.get_vocabulary()}) \
  .to_csv(MOVIE_VOCAB_CSV, index=False)

# ─── 4) Define & train the two-tower model ───────────────────────
class RetrievalModel(tfrs.models.Model):
    def __init__(self):
        super().__init__()
        self.user_model  = tf.keras.Sequential([
            user_vocab,
            tf.keras.layers.Embedding(user_vocab.vocabulary_size(), 64)
        ])
        self.movie_model = tf.keras.Sequential([
            movie_vocab,
            tf.keras.layers.Embedding(movie_vocab.vocabulary_size(), 64)
        ])
        self.task = tfrs.tasks.Retrieval()

    def compute_loss(self, features, training=False):
        return self.task(
            self.user_model(features["user_id"]),
            self.movie_model(features["movie_id"])
        )

model = RetrievalModel()
model.compile(optimizer=tf.keras.optimizers.Adagrad(0.5))
model.fit(train_ds, validation_data=val_ds, epochs=3)

# ─── 5) Save each tower as a SavedModel ─────────────────────────
USER_MODEL_DIR.mkdir(parents=True, exist_ok=True)
MOVIE_MODEL_DIR.mkdir(parents=True, exist_ok=True)
model.user_model.save(USER_MODEL_DIR, save_format="tf")
model.movie_model.save(MOVIE_MODEL_DIR, save_format="tf")

print("✅ Training complete, artifacts written to models/")
