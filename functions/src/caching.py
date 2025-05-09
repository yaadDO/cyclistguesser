from firebase_functions import https_fn
from firebase_admin import initialize_app, firestore
from procyclingstats import Ranking, Rider

app = initialize_app()
db = firestore.client()

@https_fn.on_request()
def update_cyclists_cache(req: https_fn.Request) -> https_fn.Response:
    try:
        ranking = Ranking("rankings/me/individual-season")
        riders = ranking.individual_ranking()[:100]

        batch = db.batch()
        cyclists_ref = db.collection('cyclists')

        for rider_info in riders:
            rider = Rider(rider_info['rider_url'])
            doc_ref = cyclists_ref.document(rider.relative_url())
            batch.set(doc_ref, {
                'name': rider.name(),
                'nationality': rider.nationality(),
                'teams': [t['team_name'] for t in rider.teams_history()],
                'weight': rider.weight(),
                'height': rider.height(),
                'age': calculate_age(rider.birthdate()),
                'last_updated': firestore.SERVER_TIMESTAMP
            })

        batch.commit()
        return https_fn.Response("Cache updated successfully", status=200)

    except Exception as e:
        return https_fn.Response(f"Error: {str(e)}", status=500)

def calculate_age(birthdate: str) -> int:
    from datetime import datetime
    born = datetime.strptime(birthdate, "%Y-%m-%d").date()
    today = datetime.today().date()
    return today.year - born.year - ((today.month, today.day) < (born.month, born.day))