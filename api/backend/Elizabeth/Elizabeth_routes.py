from flask import (
    Blueprint,
    request,
    jsonify,
    make_response,
    current_app,
    redirect,
    url_for,
)
import json
from backend.db_connection import db
from backend.simple.playlist import sample_playlist_data
from backend.ml_models import model01

# This blueprint handles some basic routes that you can use for testing
simple_routes = Blueprint("simple_routes", __name__)


# 1. Get Errors:
@admin.route('/error', methods=['GET'])
def get_all_errors():
    current_app.logger.info('administaror_routes.py: GET /error')
    cursor = db.get_db().cursor()
    cursor.execute('SELECT * FROM error')
    theData = cursor.fetchall()

    # the_response = make_response(###)
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# 2. Update System:

@admin.route('/update/updateID', methods=['PUT'])
def update():
    data = request.json
    cursor = db.get_db().cursor()

    query = """
        INSERT INTO `update` (adminID, updateStatus, scheduledTime, updateType, availability)
        VALUES (1, 'Scheduled', '2024-12-28 03:00:00', 'Error Based Upgrade', 'Planned Downtime');

        UPDATE `update`
        SET startTime = NOW(),
        updateStatus = 'In Progress'
        WHERE updateID = 2;

        UPDATE `update`
        SET endTime = NOW(),
        updateStatus = 'Completed',
        availability = 'Planned Downtime'
        WHERE updateID = 2;

    """
    cursor.execute(query)
    theData = cursor.fecthall()
    the_response = make_response(theData)
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response 

# 3. Contact Eboards
@admin.route('/eboard/eboardId', methods=['POST'])
def contact_eboard():
    cursor = db.get_db().cursor()
    query = '''
        SELECT e.eboardID, c.name AS clubName, e.president, e.vicePresident
        FROM eboard e
        JOIN club c ON e.clubID = c.clubID
        JOIN adminContact ac ON ac.eboardID = e.eboardID
        WHERE ac.adminID = 2
    '''
    cursor.execute(query)
    theData = cursor.fecthall()
    the_response = make_response(theData)
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

#4. Show Training

@admin.route('/adminPermissions/adminID', methods=['GET'])
def get_admin_permissions(admin_id):
    cursor = db.get_db().cursor()

    query = '''
        SELECT permission
        FROM adminPermissions
        WHERE adminID = ##
    '''
    cursor.execute(query, (admin_id,))
    theData = cursor.fetchall()

    the_response = make_response(theData)
    the_response.status_code = 200
    the_response.mimetype = 'application/json'
    return the_response

# 5. Update Notification

@admin.route('/updateNotifications', methods=['POST'])
def add_update_notification():
    cursor = db.get_db().cursor()

    query = '''
        INSERT INTO updateNotifications (notification, updateID)
        VALUES ()
    '''
    cursor.execute(query)
    theData = cursor.fetchall()

    the_response = make_response(theData)
    the_response.status_code = 200
    the_response.mimetype = 'application/json'





