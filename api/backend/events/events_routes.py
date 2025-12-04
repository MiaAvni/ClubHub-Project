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

events = Blueprint("events", __name__)


# GET registered students for a specific event
@events.route("/events/<int:eventID>/registered-students", methods=["GET"])
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
@events.route("/events/<int:eventID>", methods=["GET"])
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
@events.route("/events/<int:eventID>", methods=["PUT"])
def update_event(eventID):
    current_app.logger.info(f"PUT /events/{eventID} handler")
    
    try:
        data = request.get_json()
        
        # Check if event exists
        cursor = db.get_db().cursor()
        cursor.execute("SELECT * FROM `event` WHERE eventID = %s", (eventID,))
        if not cursor.fetchone():
            return jsonify({"error": "Event not found"}), 404
        
        # Build update query dynamically based on provided fields
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
@events.route("/events/<int:eventID>", methods=["DELETE"])
def archive_event(eventID):
    current_app.logger.info(f"DELETE /events/{eventID} handler")
    
    try:
        cursor = db.get_db().cursor()
        
        # Mark event as archived (soft delete)
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

