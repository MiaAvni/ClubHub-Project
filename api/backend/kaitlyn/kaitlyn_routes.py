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
from mysql.connector import Error

kaitlyn = Blueprint("kaitlyn", __name__)

# PUT update application status (approve or deny)
# Kaitlyn - 7
@kaitlyn.route("/applications/<int:applicationID>", methods=["PUT"])
def update_application_status(applicationID):
    current_app.logger.info(f"PUT /applications/{applicationID} handler")
    
    try:
        data = request.get_json()
        
        # Check if application exists
        cursor = db.get_db().cursor()
        cursor.execute("SELECT * FROM application WHERE applicationID = %s", (applicationID,))
        if not cursor.fetchone():
            return jsonify({"error": "Application not found"}), 404
        
        # Build update query
        update_fields = []
        params = []
        allowed_fields = ["status"]  # Can update status to 'Accepted' or 'Rejected'
        
        for field in allowed_fields:
            if field in data:
                update_fields.append(f"{field} = %s")
                params.append(data[field])
        
        if not update_fields:
            return jsonify({"error": "No valid fields to update"}), 400
        
        # Validate status value
        if data.get('status') not in ['Accepted', 'Rejected', 'Pending']:
            return jsonify({"error": "Invalid status. Must be 'Accepted', 'Rejected', or 'Pending'"}), 400
        
        params.append(applicationID)
        query = f"UPDATE application SET {', '.join(update_fields)} WHERE applicationID = %s"
        
        cursor.execute(query, params)
        db.get_db().commit()
        cursor.close()
        
        return jsonify({"message": "Application status updated successfully"}), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# DELETE remove processed application
# Kaitlyn - 7
@kaitlyn.route("/applications/<int:applicationID>", methods=["DELETE"])
def delete_application(applicationID):
    current_app.logger.info(f"DELETE /applications/{applicationID} handler")
    
    try:
        cursor = db.get_db().cursor()
        
        # Check if application exists
        cursor.execute("SELECT * FROM application WHERE applicationID = %s", (applicationID,))
        if not cursor.fetchone():
            return jsonify({"error": "Application not found"}), 404
        
        # Delete the application
        the_query = '''
            DELETE FROM application
            WHERE applicationID = %s
        '''
        
        cursor.execute(the_query, (applicationID,))
        db.get_db().commit()
        cursor.close()
        
        return jsonify({"message": "Application deleted successfully"}), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500
    
# GET interested students for a specific club
@kaitlyn.route("/clubs/<int:clubID>/interested-students", methods=["GET"])
def get_interested_students(clubID):
    current_app.logger.info(f"GET /clubs/{clubID}/interested-students handler")
    
    try:
        cursor = db.get_db().cursor()
        the_query = '''
            SELECT
                s.firstName,
                s.lastName,
                s.major,
                s.gradYear,
                se.email,
                a.dateSubmitted
            FROM application a
            JOIN student s ON a.studentID = s.studentID
            LEFT JOIN studentEmails se ON s.studentID = se.studentID
            WHERE a.clubID = %s
                AND a.status = 'Pending'
            ORDER BY a.dateSubmitted;

        '''
        
        cursor.execute(the_query, (clubID,))
        the_data = cursor.fetchall()
        cursor.close()
        
        if not the_data:
            return jsonify({"message": "No pending applications found"}), 200
        
        return jsonify(the_data), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# GET member details including tier for a specific club
@kaitlyn.route("/clubs/<int:clubID>/members/<int:memberID>", methods=["GET"])
def get_member_details(clubID, memberID):
    current_app.logger.info(f"GET /club/{clubID}/members/{memberID} handler")
    
    try:
        cursor = db.get_db().cursor()
        the_query = '''
            SELECT 
                s.studentID,
                s.firstName,
                s.lastName,
                s.major,
                s.minor,
                s.gradYear,
                s.campus,
                sj.memberType,
                sj.joinDate,
                se.email
            FROM student s
            JOIN studentJoins sj ON s.studentID = sj.studentID
            LEFT JOIN studentEmails se ON s.studentID = se.studentID
            WHERE sj.clubID = %s
                AND s.studentID = %s
        '''
        
        cursor.execute(the_query, (clubID, memberID))
        the_data = cursor.fetchone()
        cursor.close()
        
        if not the_data:
            return jsonify({"error": "Member not found in this club"}), 404
        
        return jsonify(the_data), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# PUT update member tier (e.g., general to active)
# Kaitlyn - 5
@kaitlyn.route("/clubs/<int:clubID>/members/<int:memberID>", methods=["PUT"])
def update_member_tier(clubID, memberID):
    current_app.logger.info(f"PUT /club/{clubID}/members/{memberID} handler")
    
    try:
        data = request.get_json()
        
        # Check if member exists in this club
        cursor = db.get_db().cursor()
        cursor.execute(
            "SELECT * FROM studentJoins WHERE studentID = %s AND clubID = %s",
            (memberID, clubID)
        )
        if not cursor.fetchone():
            return jsonify({"error": "Member not found in this club"}), 404
        
        # Build update query
        update_fields = []
        params = []
        allowed_fields = ["memberType"]
        
        for field in allowed_fields:
            if field in data:
                update_fields.append(f"{field} = %s")
                params.append(data[field])
        
        if not update_fields:
            return jsonify({"error": "No valid fields to update"}), 400
        
        params.extend([memberID, clubID])
        query = f"UPDATE studentJoins SET {', '.join(update_fields)} WHERE studentID = %s AND clubID = %s"
        
        cursor.execute(query, params)
        db.get_db().commit()
        cursor.close()
        
        return jsonify({"message": "Member tier updated successfully"}), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# GET events the club is hosting
# Kaitlyn - 6
@kaitlyn.route("/clubs/<int:clubID>/events", methods=["GET"])
def get_club_events(clubID):
    current_app.logger.info(f"GET /club/{clubID}/events handler")
    
    try:
        cursor = db.get_db().cursor()
        the_query = '''
            SELECT
                e.eventID,
                e.name AS eventName,
                e.date,
                e.startTime,
                e.endTime,
                e.location,
                e.description,
                e.capacity,
                e.numRegistered,
                e.isFull,
                e.isArchived,
                e.tierRequirement,
                e.capacity - e.numRegistered AS spotsRemaining
            FROM event e
            JOIN clubEvents ce ON e.eventID = ce.eventID
            WHERE ce.clubID = %s
                AND e.date >= CURDATE()
                AND e.isArchived = 0
            ORDER BY e.date
        '''
        
        cursor.execute(the_query, (clubID,))
        the_data = cursor.fetchall()
        cursor.close()
        
        if not the_data:
            return jsonify({"message": "No upcoming events found"}), 200
        
        return jsonify(the_data), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# POST create new event on club page
# Kaitlyn - 8
@kaitlyn.route("/clubs/<int:clubID>/events", methods=["POST"])
def create_club_event(clubID):
    current_app.logger.info(f"POST /club/{clubID}/events handler")
    
    try:
        data = request.get_json()
        
        # Validate required fields
        required_fields = ["name", "date", "startTime", "endTime", "location", "description", "capacity"]
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing required field: {field}"}), 400
        
        cursor = db.get_db().cursor()
        
        # Insert new event
        event_query = '''
            INSERT INTO `event` 
            (name, date, startTime, endTime, location, description, capacity, 
             numRegistered, isFull, isArchived, tierRequirement)
            VALUES (%s, %s, %s, %s, %s, %s, %s, 0, 0, 0, %s)
        '''
        
        # Set default tier requirement if not provided
        tier_requirement = data.get('tierRequirement', 'Open')
        
        cursor.execute(event_query, (
            data['name'],
            data['date'],
            data['startTime'],
            data['endTime'],
            data['location'],
            data['description'],
            data['capacity'],
            tier_requirement
        ))
        
        # Get the newly created eventID
        new_event_id = cursor.lastrowid
        
        # Link event to club in clubEvents table
        club_event_query = '''
            INSERT INTO clubEvents (clubID, eventID)
            VALUES (%s, %s)
        '''
        
        cursor.execute(club_event_query, (clubID, new_event_id))
        
        db.get_db().commit()
        cursor.close()
        
        return jsonify({
            "message": "Event created successfully",
            "eventID": new_event_id
        }), 201
        
    except Error as e:
        return jsonify({"error": str(e)}), 500


# GET all pending applications for a specific club
# Kaitlyn - 7
@kaitlyn.route("/clubs/<int:clubID>/applications", methods=["GET"])
def get_club_applications(clubID):
    current_app.logger.info(f"GET /clubs/{clubID}/applications handler")
    
    try:
        cursor = db.get_db().cursor()
        the_query = '''
            SELECT
                a.applicationID,
                s.studentID,
                s.firstName,
                s.lastName,
                s.major,
                s.gradYear,
                se.email,
                a.dateSubmitted,
                a.status
            FROM application a
            JOIN student s ON a.studentID = s.studentID
            LEFT JOIN studentEmails se ON s.studentID = se.studentID
            WHERE a.clubID = %s
                AND a.status = 'Pending'
            ORDER BY a.dateSubmitted
        '''
        
        cursor.execute(the_query, (clubID,))
        the_data = cursor.fetchall()
        cursor.close()
        
        if not the_data:
            return jsonify({"message": "No pending applications found"}), 200
        
        return jsonify(the_data), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# GET all members of a specific club
@kaitlyn.route("/clubs/<int:clubID>/members", methods=["GET"])
def get_club_members(clubID):
    current_app.logger.info(f"GET /clubs/{clubID}/members handler")
    
    try:
        cursor = db.get_db().cursor()
        the_query = '''
            SELECT 
                s.studentID,
                s.firstName,
                s.lastName,
                s.major,
                s.gradYear,
                sj.memberType,
                sj.joinDate,
                se.email
            FROM student s
            JOIN studentJoins sj ON s.studentID = sj.studentID
            LEFT JOIN studentEmails se ON s.studentID = se.studentID
            WHERE sj.clubID = %s
            ORDER BY s.lastName, s.firstName
        '''
        
        cursor.execute(the_query, (clubID,))
        the_data = cursor.fetchall()
        cursor.close()
        
        if not the_data:
            return jsonify({"message": "No members found"}), 200
        
        return jsonify(the_data), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# GET registered students for a specific event
@kaitlyn.route("/events/<int:eventID>/registered-students", methods=["GET"])
def get_registered_students(eventID):
    current_app.logger.info(f"GET /events/{eventID}/registered-students handler")
    
    try:
        cursor = db.get_db().cursor()
        the_query = '''
            SELECT
                s.firstName,
                s.lastName,
                se2.email
            FROM studentEvents se
            JOIN student s ON se.studentID = s.studentID
            JOIN studentEmails se2 ON s.studentID = se2.studentID
            WHERE se.eventID = %s
            ORDER BY s.lastName, s.firstName
        '''
        
        cursor.execute(the_query, (eventID,))
        the_data = cursor.fetchall()
        cursor.close()
        
        if not the_data:
            return jsonify({"message": "No registered students found"}), 200
        
        return jsonify(the_data), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500
    
# GET event details including capacity
@kaitlyn.route("/events/<int:eventID>", methods=["GET"])
def get_event_details(eventID):
    current_app.logger.info(f"GET /events/{eventID} handler")
    
    try:
        cursor = db.get_db().cursor()
        the_query = '''
            SELECT 
                eventID,
                name,
                date,
                startTime,
                endTime,
                location,
                description,
                capacity,
                numRegistered,
                isFull,
                isArchived,
                tierRequirement
            FROM event
            WHERE eventID = %s
        '''
        
        cursor.execute(the_query, (eventID,))
        the_data = cursor.fetchone()
        cursor.close()
        
        if not the_data:
            return jsonify({"error": "Event not found"}), 404
        
        return jsonify(the_data), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500

# PUT update event (mark as full, set tier restrictions)
@kaitlyn.route("/events/<int:eventID>", methods=["PUT"])
def update_event(eventID):
    current_app.logger.info(f"PUT /events/{eventID} handler")
    
    try:
        data = request.get_json()
        
        # Check if event exists
        cursor = db.get_db().cursor()
        cursor.execute("SELECT * FROM `event` WHERE eventID = %s", (eventID,))
        if not cursor.fetchone():
            return jsonify({"error": "Event not found"}), 404
        
        update_fields = []
        params = []
        allowed_fields = ["isFull", "tierRequirement", "capacity", "numRegistered", "location", "date", "startTime", "endTime"]
        
        for field in allowed_fields:
            if field in data:
                update_fields.append(f"{field} = %s")
                params.append(data[field])
        
        if not update_fields:
            return jsonify({"error": "No valid fields to update"}), 400
        
        params.append(eventID)
        query = f"UPDATE `event` SET {', '.join(update_fields)} WHERE eventID = %s"
        
        cursor.execute(query, params)
        db.get_db().commit()
        cursor.close()
        
        return jsonify({"message": "Event updated successfully"}), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500
    
# DELETE archive/remove past events
@kaitlyn.route("/events/<int:eventID>", methods=["DELETE"])
def archive_event(eventID):
    current_app.logger.info(f"DELETE /events/{eventID} handler")
    
    try:
        cursor = db.get_db().cursor()
        
        the_query = '''
            UPDATE `event`
            SET isArchived = 1
            WHERE eventID = %s
        '''
        
        cursor.execute(the_query, (eventID,))
        db.get_db().commit()
        cursor.close()
        
        if cursor.rowcount == 0:
            return jsonify({"error": "Event not found"}), 404
        
        return jsonify({"message": "Event archived successfully"}), 200
        
    except Error as e:
        return jsonify({"error": str(e)}), 500



