from flask import Blueprint, jsonify, request, make_response
from backend.db_connection import db
from mysql.connector import Error
from flask import current_app

# Create a Blueprint for  routes
willow = Blueprint("willow", __name__)


# story 3
# get data about how many searches each club has
@willow.route('/clubs/num-searches', methods=["GET"])
def get_club_searches():
    try:
        current_app.logger.info('Starting get_club_searches request')
        cursor = db.get_db().cursor()

        query = 'SELECT club.name, SUM(club.numSearches)\
                    FROM club\
                    GROUP BY club.name\
                    ORDER BY club.name;'

        cursor.execute(query)
        searches = cursor.fetchall()

        response = make_response(searches)
        response.status_code = 200
        response.mimetype = 'application/json'
        
        
        return response

    except Error as e:
        current_app.logger.error(f'Database error in get_club_searches: {str(e)}')
        return jsonify({"error": str(e)}), 500
