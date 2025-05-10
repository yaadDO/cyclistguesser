from procyclingstats import Rider, Ranking
from datetime import datetime
import random
from flask_cors import CORS
from flask import Flask, jsonify, request  # Add request to imports

app = Flask(__name__)
CORS(app)

def get_random_rider_url():
    """Fetches random rider URL from current season rankings"""
    ranking = Ranking("rankings/me/individual-season")
    riders = ranking.individual_ranking()[:100]  # Top 100 riders
    return random.choice([r['rider_url'] for r in riders])

@app.route('/random-rider')
def random_rider():
    """Endpoint to get random rider data"""
    try:
        rider_url = get_random_rider_url()
        rider = Rider(rider_url)
        data = rider.parse()

        # Calculate age
        birthdate = datetime.strptime(data['birthdate'], '%Y-%m-%d')
        today = datetime.now()
        age = today.year - birthdate.year - ((today.month, today.day) < (birthdate.month, birthdate.day))

        # Get current team (first item in teams_history is most recent)
        teams = data.get('teams_history', [])
        current_team = teams[0]['team_name'] if teams else 'No team'

        return jsonify({
            'name': data.get('name'),
            'nationality': data.get('nationality'),
            'team': current_team,
            'age': age,
            'weight': data.get('weight')
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

@app.route('/search-riders')
def search_riders():
    query = request.args.get('query', '').lower()
    try:
        ranking = Ranking("rankings/me/individual-season")
        riders = ranking.individual_ranking()[:500]

        # Filter names starting with query (case-insensitive)
        matches = [
                      r for r in riders
                      if r['rider_name'].lower().startswith(query)
                  ][:10]

        return jsonify([{
            'name': r['rider_name'],
            'url': r['rider_url']
        } for r in matches])

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/all-riders')
def all_riders():
    try:
        ranking = Ranking("rankings/me/individual-season")
        riders = ranking.individual_ranking()
        return jsonify([r['rider_name'] for r in riders])
    except Exception as e:
        return jsonify({'error': str(e)}), 500