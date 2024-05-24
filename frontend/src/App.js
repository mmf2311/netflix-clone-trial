import React, { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [movies, setMovies] = useState([]);

  useEffect(() => {
    fetch('/api/movies')
      .then(response => response.json())
      .then(data => setMovies(data.results));
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>Netflix Clone</h1>
      </header>
      <main>
        <h2>Popular Movies</h2>
        <div className="movies">
          {movies.map(movie => (
            <div key={movie.id} className="movie">
              <h3>{movie.title}</h3>
              <img src={`https://image.tmdb.org/t/p/w200${movie.poster_path}`} alt={movie.title} />
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}

export default App;
