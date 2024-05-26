from flask import Flask, jsonify
import requests
import os

app = Flask(__name__)

TMDB_API_KEY = os.getenv("TMDB_API_KEY")

@app.route('/movies', methods=['GET'])
def get_movies():
    response = requests.get(f'https://api.themoviedb.org/3/movie/popular?api_key={TMDB_API_KEY}')
    return jsonify(response.json())

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
