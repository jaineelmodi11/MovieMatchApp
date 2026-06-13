# ── Flask ML / embeddings service ──
FROM python:3.12-slim
WORKDIR /app
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential gcc \
 && rm -rf /var/lib/apt/lists/*
COPY movie-backend/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt
COPY movie-backend/service.py ./service.py
# fine-tuned MiniLM model (git submodule — run `git submodule update --init` first)
COPY finetuned_embedding ./finetuned_embedding
EXPOSE 5000
CMD ["python", "service.py"]
