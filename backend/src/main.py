from flask import Flask, jsonify, request
import os
from utils import get_movie_data

app = Flask(__name__)

@app.route('/movies')
def get_movies():
    title = request.args.get('title')
    if title:
        data = get_movie_data(title)
    else:
        data = {"error": "Please provide a movie title."}
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
