// server.js

require('dotenv').config();
const express  = require('express');
const cors     = require('cors');
const { Pool } = require('pg');
const axios    = require('axios');

const app = express();
const port = process.env.PORT || 3000;

const TMDB_API_KEY    = process.env.TMDB_API_KEY    || '';
const AI_SERVICE_BASE = process.env.AI_SERVICE_BASE || '';
const AI_SERVICE_KEY  = process.env.AI_SERVICE_KEY  || '';

// ─── Env checks ───────────────────────────────────────────────────────────────
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

// ─── Popular movies (swipe deck) ──────────────────────────────────────────────
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

// ─── Import or Get User ID ───────────────────────────────────────────────────
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
  try {
    const { rows } = await pool.query(text, [firebaseUid, displayName || null]);
    res.json({ userId: rows[0].id });
  } catch (err) {
    console.error('DB error in /users/importOrGetId:', err);
    res.status(500).json({ error: 'db error' });
  }
});

// ─── Proxy Content-Based Recs ────────────────────────────────────────────────
async function proxyContent(req, res) {
  const userId = Number(req.params.userId) || 1;
  const url    = `${AI_SERVICE_BASE}/recommendations/content/${userId}`;
  try {
    const aiResp = await axios.get(url, {
      headers: { 'Authorization': `Bearer ${AI_SERVICE_KEY}` }
    });
    res.json(aiResp.data);
  } catch (err) {
    console.error('Error fetching content recs:', err.message || err.response?.data);
    res.status(err.response?.status || 500).json([]);
  }
}

app.get('/recommendations/content/:userId', proxyContent);

// ─── Start Server ─────────────────────────────────────────────────────────────
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
