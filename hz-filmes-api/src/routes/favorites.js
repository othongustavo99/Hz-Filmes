const express = require('express');
const pool = require('../db');

const router = express.Router();
const DEMO_USER_ID = 1;

router.get('/', async (_req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT movie_id, title, poster_path, vote_average, release_date
       FROM favorites WHERE user_id = ? ORDER BY created_at DESC`,
      [DEMO_USER_ID]
    );
    res.json(rows);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'erro ao listar favoritos' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { movieId, title, posterPath, voteAverage, releaseDate } = req.body;
    if (!movieId) {
      return res.status(400).json({ error: 'movieId obrigatório' });
    }

    await pool.execute(
      `INSERT INTO favorites
        (user_id, movie_id, title, poster_path, vote_average, release_date)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
         title = VALUES(title),
         poster_path = VALUES(poster_path),
         vote_average = VALUES(vote_average),
         release_date = VALUES(release_date)`,
      [
        DEMO_USER_ID,
        Number(movieId),
        title || null,
        posterPath || null,
        voteAverage ?? 0,
        releaseDate || null,
      ]
    );

    res.status(201).json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'erro ao salvar favorito' });
  }
});

router.delete('/:movieId', async (req, res) => {
  try {
    await pool.execute(
      'DELETE FROM favorites WHERE user_id = ? AND movie_id = ?',
      [DEMO_USER_ID, Number(req.params.movieId)]
    );
    res.json({ ok: true });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'erro ao remover favorito' });
  }
});

module.exports = router;