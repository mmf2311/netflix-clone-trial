const express = require('express');
const app = express();
const port = 4000;

// Import the movies route
const moviesRoute = require('./movies');

app.use('/api', moviesRoute);

app.get('/', (req, res) => {
  res.send('Hello from Netflix Clone Backend!');
});

app.listen(port, () => {
  console.log(`Backend running at http://localhost:${port}`);
});
