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

applications = Blueprint("applications", __name__)

# PUT update application status (approve or deny)
# Kaitlyn - 7
@applications.route("/applications/<int:applicationID>", methods=["PUT"])
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
@applications.route("/applications/<int:applicationID>", methods=["DELETE"])
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