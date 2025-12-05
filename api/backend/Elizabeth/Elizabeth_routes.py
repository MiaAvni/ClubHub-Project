# all routes relating to Elizabeth persona 
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
from mysql.connector import Error
# from backend.simple.playlist import sample_playlist_data
# from backend.ml_models import model01
Elizabeth = Blueprint("Elizabeth", __name__)

# welcome message for admin page
@Elizabeth.route("/")
def welcome_admin():
    current_app.logger.info("GET / handler")
    welcome_message = "<h1>Welcome Administrator!"
    response = make_response(welcome_message)
    response.status_code = 200
    return response

# get all errors (GET)
@Elizabeth.route("/error", methods=["GET"])
def get_all_errors():
    try:
        current_app.logger.info('Retrieving all errors')
        cursor = db.get_db().cursor()
        
        # Get query parameters for filtering
        type = request.args.get("errorType")
        time_reported = request.args.get("timeReported")
        
        query = "SELECT * FROM Error"
        params = []
        
        if type:
            query += " AND type = %s"
            params.append(type)
        if time_reported:
            query += " AND time_reported = %s"
            params.append(time_reported)
        
        cursor.execute(query, params)
        errors = cursor.fetchall()
        cursor.close()
        
        current_app.logger.info(f'Successfully retrieved {len(errors)} errors.')
        return jsonify(errors), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in get_all_errors: {str(e)}')
        return jsonify({"error": str(e)}), 500
    
    

# get a specific error (GET)
@Elizabeth.route("/error/<int:error_id>", methods=["GET"])
def get_error(error_id):
    """
    Get details of a specific error by ID
    """
    try:
        current_app.logger.info(f'Retrieving error with ID: {error_id}')
        cursor = db.get_db().cursor()
        
        # Query to get specific error
        cursor.execute("SELECT * FROM Error WHERE errorID = %s", (error_id,))
        error = cursor.fetchone()
        
        if not error:
            current_app.logger.warning(f'Error ID {error_id} not found')
            return jsonify({"error": "Error not found"}), 404
        
        cursor.close()
        current_app.logger.info(f'Successfully retrieved error ID: {error_id}')
        return jsonify(error), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in get_error: {str(e)}')
        return jsonify({"error": str(e)}), 500
    

    
# Remove an error once solved (DELETE)
@Elizabeth.route("/error/<int:error_id>", methods=["DELETE"])
def delete_error(error_id):
    """
    Delete an error after it has been solved
    """
    try:
        current_app.logger.info(f'Deleting error ID: {error_id}')
        cursor = db.get_db().cursor()
        
        # Does error still exist
        cursor.execute("SELECT * FROM Error WHERE errorID = %s", (error_id,))
        if not cursor.fetchone():
            current_app.logger.warning(f'Error ID {error_id} not found for deletion')
            return jsonify({"error": "Error not found"}), 404
        
        # Delete the error
        cursor.execute("DELETE FROM Error WHERE errorID = %s", (error_id,))
        db.get_db().commit()
        cursor.close()
        
        current_app.logger.info(f'Successfully deleted error ID: {error_id}')
        return jsonify({"message": "Error deleted successfully", "deleted_error_id": error_id}), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in delete_error: {str(e)}')
        return jsonify({"error": str(e)}), 500
    
# Get all updates (GET)
@Elizabeth.route("/update", methods=["GET"])
def get_all_updates():
    try:
        current_app.logger.info('Retrieving all updates')
        cursor = db.get_db().cursor()
        
        # Get query parameters for filtering
        type = request.args.get("updateType")
        update_id = request.args.get("updateID")
        availability = request.args.get("availability")
        time_scheduled = request.args.get("scheduledTime")
        
        query = "SELECT * FROM Update"
        params = []
        
        if type:
            query += " AND type = %s"
            params.append(type)
        if update_id:
            query += " AND update_id = %s"
            params.append(update_id)
        if availability:
            query += " AND availability = %s"
            params.append(availability)
        if time_scheduled:
            query += " AND time_scheduled = %s"
            params.append(time_scheduled)
        
        cursor.execute(query, params)
        updates = cursor.fetchall()
        cursor.close()
        
        current_app.logger.info(f'Successfully retrieved {len(updates)} updates.')
        return jsonify(updates), 200
        
    except Error as e:
        current_app.logger.error(f'Database update in get_all_updates: {str(e)}')
        return jsonify({"error": str(e)}), 500
    

# show a specific update (GET)
@Elizabeth.route("/update/<int:update_id>", methods=["GET"])
def get_update(update_id):
    """
    Get details of a specific update by ID
    """
    try:
        current_app.logger.info(f'Retrieving update with ID: {update_id}')
        cursor = db.get_db().cursor()
        
        # Query to get specific update
        cursor.execute("SELECT * FROM update WHERE updateID = %s", (update_id,))
        update = cursor.fetchone()
        
        if not update:
            current_app.logger.warning(f'Update ID {update} not found')
            return jsonify({"update": "Update not found"}), 404
        
        cursor.close()
        current_app.logger.info(f'Successfully retrieved update ID: {update_id}')
        return jsonify(update), 200
        
    except Error as e:
        current_app.logger.error(f'Database update in get_update: {str(e)}')
        return jsonify({"error": str(e)}), 500
    
# update the status of an update (PUT)
@Elizabeth.route("/update/<int:update_id>", methods=["PUT"])
def update_update_status(update_id):
    """
    Update the status or other fields of an update
    """
    try:
        current_app.logger.info(f'Updating update ID: {update_id}')
        data = request.get_json()

        cursor = db.get_db().cursor()
        
        # Check if update exists
        cursor.execute("SELECT * FROM `Update` WHERE updateID = %s", (update_id,))
        if not cursor.fetchone():
            current_app.logger.warning(f'Update ID {update_id} not found')
            return jsonify({"error": "Update not found"}), 404

        # Build update query dynamically based on provided fields
        update_fields = []
        params = []
        
        allowed_fields = ["adminId", "updateStatus", "scheduledTime", "startTime", "endTime", "updateType", "avaiability"]

        for field in allowed_fields:
            if field in data:
                update_fields.append(f"{field} = %s")
                params.append(data[field])

        if not update_fields:
            return jsonify({"error": "No valid fields to update"}), 400

        params.append(update_id)
        query = f"UPDATE `Update` SET {', '.join(update_fields)} WHERE updateID = %s"

        cursor.execute(query, params)
        db.get_db().commit()
        cursor.close()

        current_app.logger.info(f'Successfully updated update ID: {update_id}')
        return jsonify({"message": "Update status updated successfully"}), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in update_update_status: {str(e)}')
        return jsonify({"error": str(e)}), 500
    

# create a new notification (POST)
@Elizabeth.route("/updateNotifications/notification", methods=["POST"])
def create_notification():
    """
    Creates a new notification
    """
    try:
        current_app.logger.info('Creating new notification')
        data = request.get_json()

        # Validate required fields
        required_fields = ["notification", "updateID"]
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing required field: {field}"}), 400

        cursor = db.get_db().cursor()

        # Insert new notification
        query = """
        INSERT INTO UpdateNotifications (notification, updateID)
        VALUES (%s, %s)
        """
        cursor.execute(
            query,
            (
                data["notification"],
                data["updateID"],
            ),
        )

        db.get_db().commit()
        new_notification_id = cursor.lastrowid
        cursor.close()

        current_app.logger.info(f'Successfully created notification with ID: {new_notification_id}')
        return (
            jsonify({"message": "Notification created successfully", "notification_id": new_notification_id}),
            201,
        )
    except Error as e:
        current_app.logger.error(f'Database error in create_notification: {str(e)}')
        return jsonify({"error": str(e)}), 500
    

 # show all admin permissions (GET)
@Elizabeth.route("/adminPermissions", methods=["GET"])
def get_all_admin_permissions():
    try:
        current_app.logger.info('Retrieving all admin permissions')
        cursor = db.get_db().cursor()
        
        # Get query parameters for filtering
        admin_id = request.args.get("adminID")
        permission = request.args.get("permission")
        
        query = "SELECT * FROM AdminPermissions"
        params = []
        
        if admin_id:
            query += " WHERE adminID = %s"
            params.append(admin_id)
            if permission:
                query += " AND permission = %s"
                params.append(permission)
        elif permission:
            query += " WHERE permission = %s"
            params.append(permission)
        
        cursor.execute(query, params)
        permissions = cursor.fetchall()
        cursor.close()
        
        current_app.logger.info(f'Successfully retrieved {len(permissions)} admin permissions.')
        return jsonify(permissions), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in get_all_admin_permissions: {str(e)}')
        return jsonify({"error": str(e)}), 500
    

# show permissions of a specific administrator (GET)
@Elizabeth.route("/adminPermissions/<int:admin_id>", methods=["GET"])
def get_admin_permissions(admin_id):
    """
    Shows the permissions of a particular administrator
    """
    try:
        current_app.logger.info(f'Fetching permissions for admin ID: {admin_id}')
        cursor = db.get_db().cursor()
        
        cursor.execute("SELECT * FROM AdminPermissions WHERE adminID = %s", (admin_id,))
        permissions = cursor.fetchone()
        
        if not permissions:
            current_app.logger.warning(f'Admin ID {admin_id} permissions not found')
            return jsonify({"error": "Admin permissions not found"}), 404
        
        cursor.close()
        current_app.logger.info(f'Successfully retrieved permissions for admin ID: {admin_id}')
        return jsonify(permissions), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in get_admin_permissions: {str(e)}')
        return jsonify({"error": str(e)}), 500
    
    
# Changes the permissions of a particular administrator (PUT)
@Elizabeth.route("/adminPermissions/<int:admin_id>", methods=["PUT"])
def update_admin_permissions(admin_id):
    """
    Changes permissions of a particular administrator
    """
    try:
        current_app.logger.info(f'Updating permissions for admin ID: {admin_id}')
        data = request.get_json()
        cursor = db.get_db().cursor()
        
        # Check if admin permissions exist
        cursor.execute("SELECT * FROM AdminPermissions WHERE adminID = %s", (admin_id,))
        if not cursor.fetchone():
            current_app.logger.warning(f'Admin ID {admin_id} permissions not found')
            return jsonify({"error": "Admin permissions not found"}), 404

        # Build update query dynamically
        update_fields = []
        params = []
   

        allowed_fields = ["adminID", "permission"]

        for field in allowed_fields:
            if field in data:
                update_fields.append(f"{field} = %s")
                params.append(data[field])

        if not update_fields:
            return jsonify({"error": "No valid fields to update"}), 400

        params.append(admin_id)
        query = f"UPDATE AdminPermissions SET {', '.join(update_fields)} WHERE adminID = %s"

        cursor.execute(query, params)
        db.get_db().commit()
        cursor.close()

        current_app.logger.info(f'Successfully updated permissions for admin ID: {admin_id}')
        return jsonify({"message": "Admin permissions updated successfully"}), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in update_admin_permissions: {str(e)}')
        return jsonify({"error": str(e)}), 500


# Creates a new permission for a new administrator (POST)
@Elizabeth.route("/adminPermissions", methods=["POST"])
def create_admin_permissions():
    """
    Creates new permissions for a new administrator
    Example: POST /elizabeth/adminPermissions with JSON body
    """
    try:
        current_app.logger.info('Creating new admin permissions')
        data = request.get_json()

        # Validate required fields
        required_fields = ["adminID", "permission"]
        for field in required_fields:
            if field not in data:
                return jsonify({"error": f"Missing required field: {field}"}), 400

        cursor = db.get_db().cursor()

        # Insert new admin permissions
        query = """
        INSERT INTO AdminPermissions (adminID, permission)
        VALUES (%s, %s)
        """
        cursor.execute(
            query,
            (
                data["adminID"],
                data["permission"],
            ),
        )

        db.get_db().commit()
        new_permission_id = cursor.lastrowid
        cursor.close()

        current_app.logger.info(f'Successfully created permissions with ID: {new_permission_id}')
        return (
            jsonify({"message": "Admin permissions created successfully", "permission_id": new_permission_id}),
            201,
        )
    except Error as e:
        current_app.logger.error(f'Database error in create_admin_permissions: {str(e)}')
        return jsonify({"error": str(e)}), 500



# Get all eboard contacts (GET)
@Elizabeth.route("/adminContact", methods=["GET"])
def get_all_eboard_contacts():
    try:
        current_app.logger.info('Retrieving all eboard contacts')
        cursor = db.get_db().cursor()
        
        # Get query parameters for filtering
        eboard_id = request.args.get("eboardID")
        admin_id = request.args.get("adminID")
        
        query = "SELECT * FROM EboardContact"
        params = []
        
        if eboard_id:
            query += " WHERE eboardID = %s"
            params.append(eboard_id)
            if admin_id:
                query += " AND adminID = %s"
                params.append(admin_id)
        elif admin_id:
            query += " WHERE adminID = %s"
            params.append(admin_id)
        
        cursor.execute(query, params)
        contacts = cursor.fetchall()
        cursor.close()
        
        current_app.logger.info(f'Successfully retrieved {len(contacts)} eboard contacts.')
        return jsonify(contacts), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in get_all_eboard_contacts: {str(e)}')
        return jsonify({"error": str(e)}), 500
    


# Show the way to contact a particular club E-board (GET)
@Elizabeth.route("/adminContact/<int:eboard_id>", methods=["GET"])
def get_eboard_contact(eboard_id):
    """
    Show the way to contact a particular club E-board
    """
    try:
        current_app.logger.info(f'Fetching contact info for E-board ID: {eboard_id}')
        cursor = db.get_db().cursor()
        
        cursor.execute("SELECT * FROM EboardContact WHERE eboardID = %s", (eboard_id,))
        contact = cursor.fetchone()
        
        if not contact:
            current_app.logger.warning(f'E-board ID {eboard_id} contact not found')
            return jsonify({"error": "E-board contact not found"}), 404
        
        cursor.close()
        current_app.logger.info(f'Successfully retrieved contact for E-board ID: {eboard_id}')
        return jsonify(contact), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in get_eboard_contact: {str(e)}')
        return jsonify({"error": str(e)}), 500
    


# Get all system errors (GET)
@Elizabeth.route("/system/error", methods=["GET"])
def get_all_system_errors():
    """
    Get all system errors with optional filtering
    """
    try:
        current_app.logger.info('Retrieving all system errors')
        cursor = db.get_db().cursor()
        
        # Get query parameters for filtering
        system_id = request.args.get("systemID")
        error_type = request.args.get("errorType")
        
        if system_id and error_type:
            cursor.execute("SELECT * FROM error WHERE systemID = %s AND errorType = %s", (system_id, error_type))
        elif system_id:
            cursor.execute("SELECT * FROM error WHERE systemID = %s", (system_id,))
        elif error_type:
            cursor.execute("SELECT * FROM error WHERE errorType = %s", (error_type,))
        else:
            cursor.execute("SELECT * FROM error")
        
        errors = cursor.fetchall()
        cursor.close()
        
        current_app.logger.info(f'Successfully retrieved {len(errors)} system errors')
        return jsonify(errors), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in get_all_system_errors: {str(e)}')
        return jsonify({"error": str(e)}), 500

# Show the particular error a system network has (GET)
@Elizabeth.route("/system/error/<int:error_id>", methods=["GET"])
def get_system_error(error_id):
    """
    Show the particular error a system network has
    """
    try:
        current_app.logger.info(f'Fetching system error with ID: {error_id}')
        cursor = db.get_db().cursor()
        
        cursor.execute("SELECT * FROM error WHERE errorID = %s", (error_id,))
        error = cursor.fetchone()
        
        if not error:
            current_app.logger.warning(f'System error ID {error_id} not found')
            return jsonify({"error": "System error not found"}), 404
        
        cursor.close()
        current_app.logger.info(f'Successfully retrieved system error ID: {error_id}')
        return jsonify(error), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in get_system_error: {str(e)}')
        return jsonify({"error": str(e)}), 500
    


# Removes a  particular error a system network has (DELETE)
@Elizabeth.route("/system/error/<int:error_id>", methods=["DELETE"])
def delete_system_error(error_id):
    """
    Removes a particular error a system network has
    """
    try:
        current_app.logger.info(f'Deleting system error ID: {error_id}')
        cursor = db.get_db().cursor()
        
        # Check if system error exists
        cursor.execute("SELECT * FROM error WHERE errorID = %s", (error_id,))
        if not cursor.fetchone():
            current_app.logger.warning(f'System error ID {error_id} not found')
            return jsonify({"error": "System error not found"}), 404
        
        # Delete the system error
        cursor.execute("DELETE FROM error WHERE errorID = %s", (error_id,))
        db.get_db().commit()
        cursor.close()
        
        current_app.logger.info(f'Successfully deleted system error ID: {error_id}')
        return jsonify({"message": "System error deleted successfully", "deleted_error_id": error_id}), 200
        
    except Error as e:
        current_app.logger.error(f'Database error in delete_system_error: {str(e)}')
        return jsonify({"error": str(e)}), 500
