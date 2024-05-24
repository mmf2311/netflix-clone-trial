const request = require('supertest');
const express = require('express');
const moviesRoute = require('./movies');

const app = express();
app.use('/api', moviesRoute);

jest.mock('axios');
const axios = require('axios');

describe('GET /api/movies', () => {
  it('should fetch movies', async () => {
    const movies = {
      data: {
        results: [
          { id: 1, title: 'Movie 1', poster_path: '/path1' },
          { id: 2, title: 'Movie 2', poster_path: '/path2' }
        ]
      }
    };
    
    axios.get.mockResolvedValue(movies);
    
    const res = await request(app).get('/api/movies');
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.results).toHaveLength(2);
    expect(res.body.results[0].title).toEqual('Movie 1');
  });

  it('should return error on failed fetch', async () => {
    axios.get.mockRejectedValue(new Error('Failed to fetch movies'));
    
    const res = await request(app).get('/api/movies');
    
    expect(res.statusCode).toEqual(500);
    expect(res.body.error).toEqual('Failed to fetch movies');
  });
});
