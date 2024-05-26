import os
import requests

def get_movie_data(title):
    api_key = os.getenv('TMDB_API_KEY')
    url = f'https://api.themoviedb.org/3/search/movie?api_key={api_key}&query={title}'
    response = requests.get(url)
    return response.json()
