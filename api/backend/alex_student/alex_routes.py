from flask import Blueprint, jsonify, request
from backend.db_connection import db
from mysql.connector import Error
from flask import current_app
from datetime import datetime, date

# Routes for everything a student can do (search clubs, apply, update apps, etc.)
students = Blueprint("students", __name__)


# Story 1
# Let students search for clubs. They can also filter by campus or gradLevel.
# Example: /student/clubs?campus=Boston&gradLevel=undergrad
@students.route("/clubs", methods=["GET"])
def get_clubs():
    try:
        current_app.logger.info("Starting get_clubs request")
        cursor = db.get_db().cursor()

        # Base query – we add filters only if they're provided
        query = """
            SELECT clubID, name, gradLevel, campus, description,
                   numMembers, numSearches
            FROM club
            WHERE 1=1
        """

        params = []

        # Optional filters
        campus = request.args.get("campus")
        grad_level = request.args.get("gradLevel")

        if campus:
            query += " AND campus = %s"
            params.append(campus)

        if grad_level:
            query += " AND gradLevel = %s"
            params.append(grad_level)

        cursor.execute(query, params)
        clubs = cursor.fetchall()
        cursor.close()

        return jsonify(clubs), 200

    except Error as e:
        current_app.logger.error(f"Database error in get_clubs: {str(e)}")
        return jsonify({"error": str(e)}), 500


# Story 5
# Student wants to see every application they've submitted + its status
# Example: /student/applications/1
@students.route("/applications/<int:studentID>", methods=["GET"])
def get_student_applications(studentID):
    try:
        current_app.logger.info("Starting get_student_applications request")
        cursor = db.get_db().cursor()

        query = """
            SELECT applicationID, clubID, studentID,
                   DATE_FORMAT(dateSubmitted, '%%Y-%%m-%%d') as dateSubmitted, status
            FROM application
            WHERE studentID = %s
            ORDER BY dateSubmitted DESC
        """

        cursor.execute(query, (studentID,))
        apps = cursor.fetchall()
        cursor.close()

        return jsonify(apps), 200

    except Error as e:
        current_app.logger.error(f"Database error: {str(e)}")
        return jsonify({"error": str(e)}), 500


# Story 3
# Student submits an application to a club
# JSON body should look like:
# {
#   "studentID": 1,
#   "clubID": 3,
#   "dateSubmitted": "2025-12-02"
# }
@students.route("/applications", methods=["POST"])
def create_application():
    try:
        current_app.logger.info("Starting create_application request")
        data = request.get_json() or {}

        student_id = data.get("studentID")
        club_id = data.get("clubID")
        date_submitted = data.get("dateSubmitted")

        # Quick check for required fields
        if not student_id or not club_id or not date_submitted:
            return jsonify({
                "error": "studentID, clubID, and dateSubmitted are required"
            }), 400

        cursor = db.get_db().cursor()

        # Validate that student exists
        cursor.execute("SELECT studentID FROM student WHERE studentID = %s", (student_id,))
        if not cursor.fetchone():
            cursor.close()
            return jsonify({
                "error": f"Student ID {student_id} does not exist. Please use a valid student ID."
            }), 400

        # Validate that club exists
        cursor.execute("SELECT clubID FROM club WHERE clubID = %s", (club_id,))
        if not cursor.fetchone():
            cursor.close()
            return jsonify({
                "error": f"Club ID {club_id} does not exist. Please use a valid club ID."
            }), 400

        insert_query = """
            INSERT INTO application (clubID, studentID, dateSubmitted, status)
            VALUES (%s, %s, %s, %s)
        """

        cursor.execute(insert_query, (club_id, student_id, date_submitted, "pending"))
        db.get_db().commit()

        new_id = cursor.lastrowid
        cursor.close()

        return jsonify({
            "message": "Application created",
            "applicationID": new_id
        }), 201

    except Error as e:
        current_app.logger.error(f"Database error: {str(e)}")
        # Check if it's a foreign key constraint error
        error_str = str(e)
        if "foreign key constraint" in error_str.lower() or "1452" in error_str:
            if "studentID" in error_str:
                return jsonify({
                    "error": f"Student ID {student_id} does not exist. Please use a valid student ID."
                }), 400
            elif "clubID" in error_str:
                return jsonify({
                    "error": f"Club ID {club_id} does not exist. Please use a valid club ID."
                }), 400
        return jsonify({"error": str(e)}), 500


# Story 4
# Student updates their application (ex: withdraw, change status, etc.)
# JSON body: { "status": "withdrawn" }
@students.route("/applications/<int:applicationID>", methods=["PUT"])
def update_application(applicationID):
    try:
        current_app.logger.info("Starting update_application request")
        data = request.get_json() or {}
        new_status = data.get("status")

        if not new_status:
            return jsonify({"error": "status is required"}), 400

        cursor = db.get_db().cursor()

        # Check if the application exists
        cursor.execute(
            "SELECT applicationID FROM application WHERE applicationID = %s",
            (applicationID,)
        )
        if not cursor.fetchone():
            cursor.close()
            return jsonify({"error": "Application not found"}), 404

        update_query = """
            UPDATE application
            SET status = %s
            WHERE applicationID = %s
        """

        cursor.execute(update_query, (new_status, applicationID))
        db.get_db().commit()
        cursor.close()

        return jsonify({"message": "Application updated"}), 200

    except Error as e:
        current_app.logger.error(f"Database error: {str(e)}")
        return jsonify({"error": str(e)}), 500


# Story 4 (delete/withdraw an application)
# Student wants to remove an app they no longer care about
@students.route("/applications/<int:applicationID>", methods=["DELETE"])
def delete_application(applicationID):
    try:
        current_app.logger.info("Starting delete_application request")
        cursor = db.get_db().cursor()

        # Make sure the application exists
        cursor.execute(
            "SELECT applicationID FROM application WHERE applicationID = %s",
            (applicationID,)
        )
        if not cursor.fetchone():
            cursor.close()
            return jsonify({"error": "Application not found"}), 404

        cursor.execute(
            "DELETE FROM application WHERE applicationID = %s",
            (applicationID,)
        )
        db.get_db().commit()
        cursor.close()

        return jsonify({"message": "Application deleted"}), 200

    except Error as e:
        current_app.logger.error(f"Database error: {str(e)}")
        return jsonify({"error": str(e)}), 500


# Student registers for an event
# JSON body should look like:
# {
#   "studentID": 1,
#   "eventID": 5
# }
@students.route("/events", methods=["POST"])
def register_for_event():
    try:
        current_app.logger.info("Starting register_for_event request")
        data = request.get_json() or {}

        student_id = data.get("studentID")
        event_id = data.get("eventID")

        # Quick check for required fields
        if not student_id or not event_id:
            return jsonify({
                "error": "studentID and eventID are required"
            }), 400

        cursor = db.get_db().cursor()

        # Validate that student exists
        cursor.execute("SELECT studentID FROM student WHERE studentID = %s", (student_id,))
        if not cursor.fetchone():
            cursor.close()
            return jsonify({
                "error": f"Student ID {student_id} does not exist. Please use a valid student ID."
            }), 400

        # Validate that event exists and get event details
        cursor.execute("""
            SELECT eventID, capacity, numRegistered, isFull, isArchived
            FROM event
            WHERE eventID = %s
        """, (event_id,))
        event_data = cursor.fetchone()
        
        if not event_data:
            cursor.close()
            return jsonify({
                "error": f"Event ID {event_id} does not exist. Please use a valid event ID."
            }), 404

        # Check if event is archived
        if event_data.get("isArchived") == 1:
            cursor.close()
            return jsonify({
                "error": "This event has been archived and is no longer available for registration."
            }), 400

        # Check if event is full
        capacity = event_data.get("capacity", 0)
        num_registered = event_data.get("numRegistered", 0)
        is_full = event_data.get("isFull", 0)
        
        if is_full == 1 or (capacity > 0 and num_registered >= capacity):
            cursor.close()
            return jsonify({
                "error": "This event is full and cannot accept more registrations."
            }), 400

        # Check if student is already registered for this event
        cursor.execute("""
            SELECT studentID, eventID
            FROM studentEvents
            WHERE studentID = %s AND eventID = %s
        """, (student_id, event_id))
        
        if cursor.fetchone():
            cursor.close()
            return jsonify({
                "error": "You are already registered for this event."
            }), 409

        # Insert into studentEvents table
        insert_query = """
            INSERT INTO studentEvents (studentID, eventID)
            VALUES (%s, %s)
        """
        cursor.execute(insert_query, (student_id, event_id))

        # Update numRegistered count in event table
        new_num_registered = num_registered + 1
        update_query = """
            UPDATE event
            SET numRegistered = %s, isFull = %s
            WHERE eventID = %s
        """
        # Set isFull to 1 if we've reached capacity, otherwise 0
        new_is_full = 1 if (capacity > 0 and new_num_registered >= capacity) else 0
        cursor.execute(update_query, (new_num_registered, new_is_full, event_id))

        db.get_db().commit()
        cursor.close()

        return jsonify({
            "message": "Successfully registered for event",
            "studentID": student_id,
            "eventID": event_id
        }), 201

    except Error as e:
        current_app.logger.error(f"Database error: {str(e)}")
        db.get_db().rollback()
        # Check if it's a duplicate entry error (already registered)
        error_str = str(e)
        if "Duplicate entry" in error_str or "1062" in error_str:
            return jsonify({
                "error": "You are already registered for this event."
            }), 409
        # Check if it's a foreign key constraint error
        elif "foreign key constraint" in error_str.lower() or "1452" in error_str:
            if "studentID" in error_str:
                return jsonify({
                    "error": f"Student ID {student_id} does not exist. Please use a valid student ID."
                }), 400
            elif "eventID" in error_str:
                return jsonify({
                    "error": f"Event ID {event_id} does not exist. Please use a valid event ID."
                }), 400
        return jsonify({"error": str(e)}), 500
