require('dotenv').config();
const express = require('express');
const cors = require('cors');

const activityRoutes = require('./routes/activity');
const favoritesRoutes = require('./routes/favorites');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/health', (_, res) => res.json({ ok: true }));

app.use('/activity', activityRoutes);
app.use('/favorites', favoritesRoutes);

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`HZ Filmes API rodando em http://localhost:${port}`);
});