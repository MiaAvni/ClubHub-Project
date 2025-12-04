from flask import Blueprint, jsonify, request, make_response
from backend.db_connection import db
from mysql.connector import Error
from flask import current_app

# Create a Blueprint for  routes
willow = Blueprint("willow", __name__)


# story 3
# get data about how many searches each club has
@willow.route('/clubs/searches', methods=["GET"])
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

        return jsonify(searches)
        
    except Error as e:
        current_app.logger.error(f'Database error in get_club_searches: {str(e)}')
        return jsonify({"error": str(e)}), 500


# story 3
# show applications for each club
@willow.route('/clubs/applications')
def get_club_apps():
    try:
        current_app.logger.info('Starting get_club_apps request')
        cursor = db.get_db().cursor()

        query = 'SELECT club.name, COUNT(applicationID) as NumApps\
                    FROM application\
                    JOIN club ON application.clubID = club.clubID\
                    GROUP BY club.clubID;'

        cursor.execute(query)
        applications = cursor.fetchall()
        cursor.close()

        
        response = make_response(applications)
        response.status_code = 200
        response.mimetype = 'application/json'
        
        
        return response

    except Error as e:
        current_app.logger.error(f'Database error in get_club_apps: {str(e)}')
        return jsonify({"error": str(e)}), 500


# story 2
# show categories for each club
@willow.route('/clubs/categories', methods=['GET'])
def get_categories():
    try:
        current_app.logger.info('Starting get_categories request')
        cursor = db.get_db().cursor()
        
        query = 'SELECT club.name, club.clubID, category.name, category.categoryID\
                FROM club JOIN clubCategories ON club.clubID = clubCategories.clubID\
                JOIN category ON clubCategories.categoryID = category.categoryID\
                ORDER BY club.name;'

        cursor.execute(query)
        categories = cursor.fetchall()
        cursor.close()

        response = make_response(categories)
        response.status_code = 200
        response.mimetype = 'application/json'
        
        return response

    except Error as e:
        current_app.logger.error(f'Database error in get_categories: {str(e)}')
        return jsonify({"error": str(e)}), 500



# story 2
# show all demographics data for students in a specific club
@willow.route('/clubs/<int:clubID>/demographics', methods=['GET'])
def get_club_demographics(clubID):
    try:
        current_app.logger.info('Starting get_club_demographics request')
        cursor = db.get_db().cursor()

        query = f'SELECT student.studentID, student.age,\
                student.gender, student.race, student.gradYear\
                FROM student JOIN studentJoins ON\
                student.studentID = studentJoins.studentID\
                WHERE clubID = {clubID}'

        cursor.execute(query, clubID)
        demographics = cursor.fetchall()
        cursor.close()

        response = make_response(demographics)
        response.status_code = 200
        response.mimetype = 'application/json'
        
        return response

    except Error as e:
        current_app.logger.error(f'Database error in get_club_demographics: {str(e)}')
        return jsonify({"error": str(e)}), 500

# story 4
# show number of attendees for all events and the number of members the club hosting that event has
@willow.route('/events/attendees', methods=['GET'])
def get_attendees():
    try:
        current_app.logger.info('Starting get_attendees request')
        cursor = db.get_db().cursor()

        query = "SELECT club.clubID, club.name, event.eventID, event.name,\
                event.numRegistered, club.numMembers AS numClubMembers\
                FROM club JOIN clubEvents ON club.clubID = clubEvents.clubID\
                JOIN event ON clubEvents.eventID = event.eventID\
                ORDER BY clubID;"

    
        cursor.execute(query)
        attendees = cursor.fetchall()

        return jsonify(attendees)

    except Error as e:
        current_app.logger.error(f'Database error in get_club_demographics: {str(e)}')
        return jsonify({"error": str(e)}), 500

        


