// server.js

require('dotenv').config();
const express  = require('express');
const cors     = require('cors');
const { Pool } = require('pg');
const axios    = require('axios');

const app          = express();
const port         = process.env.PORT || 3000;
const TMDB_API_KEY = process.env.TMDB_API_KEY || '';
const AI_SERVICE_BASE = process.env.AI_SERVICE_BASE || '';
const AI_SERVICE_KEY  = process.env.AI_SERVICE_KEY || '';

// Ensure required environment variables are set
if (!TMDB_API_KEY) {
  console.error('❌ Missing TMDB_API_KEY in .env');
  process.exit(1);
}
if (!AI_SERVICE_BASE || !AI_SERVICE_KEY) {
  console.error('❌ Missing AI_SERVICE_BASE or AI_SERVICE_KEY in .env');
  process.exit(1);
}

app.use(cors());
app.use(express.json());

const pool = new Pool({
  user:     process.env.PG_USER     || 'postgres',
  host:     process.env.PG_HOST     || 'localhost',
  database: process.env.PG_DATABASE || 'movieswipe',
  password: process.env.PG_PASSWORD || 'Gonkilla_11',
  port:     process.env.PG_PORT     || 5432,
});

// ─── Proxy TMDB full detail ───────────────────────────────────────────────────
app.get('/movie/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const tmdbResp = await axios.get(
      `https://api.themoviedb.org/3/movie/${id}`,
      { params: { api_key: TMDB_API_KEY, language: 'en-US' } }
    );
    res.json(tmdbResp.data);
  } catch (err) {
    console.error('Error fetching TMDB detail for', id, err.message);
    res.status(500).json({});
  }
});

// ─── Popular movies (for swipe deck) ─────────────────────────────────────────
app.get('/movies', async (req, res) => {
  try {
    const tmdb = await axios.get(
      'https://api.themoviedb.org/3/movie/popular',
      { params: { api_key: TMDB_API_KEY, language: 'en-US', page: 1 } }
    );
    const list = tmdb.data.results.map(m => ({
      id:        m.id,
      title:     m.title,
      posterURL: `https://image.tmdb.org/t/p/w500${m.poster_path}`
    }));
    res.json(list);
  } catch (err) {
    console.error('Error fetching popular movies:', err.message);
    res.status(500).json([]);
  }
});

// ─── Record a swipe ──────────────────────────────────────────────────────────
app.post('/swipes', async (req, res) => {
  let { userId, movieId, direction } = req.body;
  userId  = Number(userId)  || 1;
  movieId = Number(movieId) || 0;

  console.log(`Swipe recorded → userId: ${userId}, movieId: ${movieId}, direction: ${direction}`);
  try {
    await pool.query(
      'INSERT INTO swipes (user_id, movie_id, direction) VALUES ($1, $2, $3)',
      [userId, movieId, direction]
    );
    res.json({ success: true });
  } catch (err) {
    console.error('Error inserting swipe:', err);
    res.status(500).json({ success: false });
  }
});

// ─── Map Firebase UID → small integer ID ─────────────────────────────────────
app.post('/users/importOrGetId', async (req, res) => {
  const { firebaseUid, displayName } = req.body;
  if (!firebaseUid) {
    return res.status(400).json({ error: 'firebaseUid is required' });
  }

  const text = `
    INSERT INTO users (firebase_uid, display_name)
    VALUES ($1, $2)
    ON CONFLICT (firebase_uid) DO UPDATE
      SET display_name = EXCLUDED.display_name
    RETURNING id;
  `;
  const values = [firebaseUid, displayName || null];

  try {
    const { rows } = await pool.query(text, values);
    return res.json({ userId: rows[0].id });
  } catch (err) {
    console.error('Error in /users/importOrGetId:', err);
    return res.status(500).json({ error: 'db error' });
  }
});

// ─── Helper to proxy recs with auth ────────────────────────────────────────────
async function proxyRecs(req, res, type) {
  const userId = Number(req.params.userId) || 1;
  const url    = `${AI_SERVICE_BASE}/recommendations/${type}/${userId}`;

  console.log(`[proxy] ${type} → user ${userId} → ${url}`);
  try {
    const aiResp = await axios.get(url, {
      headers: { 'Authorization': `Bearer ${AI_SERVICE_KEY}` }
    });
    return res.json(aiResp.data);
  } catch (err) {
    const status = err.response?.status || 500;
    const data   = err.response?.data   || err.message;
    console.error(`[proxy] Error fetching ${type} recs:`, status, data);
    return res.status(status).json([]);
  }
}

// ─── Recommendation routes ───────────────────────────────────────────────────
app.get('/recommendations/content/:userId', (req, res) =>
  proxyRecs(req, res, 'content')
);
app.get('/recommendations/cf/:userId', (req, res) =>
  proxyRecs(req, res, 'cf')
);
app.get('/recommendations/hybrid/:userId', (req, res) =>
  proxyRecs(req, res, 'hybrid')
);

// ─── Start Server ─────────────────────────────────────────────────────────────
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
