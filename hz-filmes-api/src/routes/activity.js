const express = require('express');
const pool = require('../db');

const router = express.Router();

// Por enquanto user_id fixo = 1 (depois vem login)
const DEMO_USER_ID = 1;

// Registrar busca
router.post('/search', async (req, res) => {
  try {
    const { query } = req.body;
    if (!query || !String(query).trim()) {
      return res.status(400).json({ error: 'query obrigatória' });
    }

    await pool.execute(
      'INSERT INTO search_history (user_id, query) VALUES (?, ?)',
      [DEMO_USER_ID, String(query).trim()]
    );

    res.status(201).json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'erro ao salvar busca' });
  }
});

// Registrar clique
router.post('/click', async (req, res) => {
  try {
    const { movieId } = req.body;
    if (!movieId) {
      return res.status(400).json({ error: 'movieId obrigatório' });
    }

    await pool.execute(
      'INSERT INTO click_history (user_id, movie_id) VALUES (?, ?)',
      [DEMO_USER_ID, Number(movieId)]
    );

    res.status(201).json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'erro ao salvar clique' });
  }
});

// Histórico (para recomendações no servidor, depois)
router.get('/history', async (_req, res) => {
  try {
    const [searches] = await pool.execute(
      `SELECT query, created_at FROM search_history
       WHERE user_id = ? ORDER BY created_at DESC LIMIT 30`,
      [DEMO_USER_ID]
    );

    const [clicks] = await pool.execute(
      `SELECT movie_id, created_at FROM click_history
       WHERE user_id = ? ORDER BY created_at DESC LIMIT 30`,
      [DEMO_USER_ID]
    );

    res.json({ searches, clicks });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'erro ao buscar histórico' });
  }
});

module.exports = router;