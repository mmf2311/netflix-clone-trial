import React, { useEffect, useState } from 'react';

function App() {
  const [movies, setMovies] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch('/api/movies');
        const data = await response.json();
        setMovies(data.results);
      } catch (error) {
        console.error('Error fetching movies:', error);
      }
    };

    fetchData();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>Netflix Clone</h1>
        {/* Render movies */}
      </header>
    </div>
  );
}

export default App;
