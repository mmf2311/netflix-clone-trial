const express = require('express');
const axios = require('axios');
const router = express.Router();

// Fetch API key from environment variables or secrets manager
const TMDB_API_KEY = process.env.TMDB_API_KEY;

router.get('/movies', async (req, res) => {
  try {
    const response = await axios.get(`https://api.themoviedb.org/3/movie/popular?api_key=${TMDB_API_KEY}`);
    res.json(response.data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch movies' });
  }
});

module.exports = router;
