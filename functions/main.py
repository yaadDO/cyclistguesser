# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn
from firebase_admin import initialize_app

# initialize_app()
#
#
# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")

from procyclingstats import Rider, Ranking
from flask import jsonify
import random
from datetime import datetime

def calculate_age(birthdate):
    born = datetime.strptime(birthdate, "%Y-%m-%d").date()
    today = datetime.today().date()
    return today.year - born.year - ((today.month, today.day) < (born.month, born.day))

def get_random_cyclist(request):
    try:
        # Get current UCI ranking
        ranking = Ranking("rankings/me/individual-season")
        riders = ranking.individual_ranking()[:50]  # Top 50 riders

        # Select random rider
        rider_info = random.choice(riders)
        rider = Rider(rider_info['rider_url'])

        # Get team from current season
        teams = rider.teams_history()
        current_team = next((t for t in teams if t['season'] == str(datetime.now().year)), teams[-1])

        # Build response
        rider_data = {
            "name": rider.name(),
            "role": "Pro Rider",  # You might need custom logic for specific roles
            "age": calculate_age(rider.birthdate()),
            "team": current_team['team_name'],
            "nationality": rider.nationality(),
            "weight": rider.weight(),
            "height": rider.height()
        }

        return jsonify(rider_data), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500