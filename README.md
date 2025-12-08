# ClubHub

ClubHub is a web application designed to help students discover and join clubs at their university. The application provides functionality for students to search for clubs, submit applications, and manage their club memberships. It also includes administrative and analytical features for club management and data analysis.

## Project Demo:
https://drive.google.com/file/d/1usG2yrZbE2a3y2lzD4s4LVWXV3cRlR0M/view?usp=sharing 

## Student Functionality (Alex)

The Student persona functionality allows students to search for clubs, view their applications, submit new applications, update application status, and delete/withdraw applications.

### API Routes

The Student blueprint (`api/backend/alex-student/alex_routes.py`) provides 5 REST API endpoints under the `/student` URL prefix:

#### Search Clubs

- **Endpoint**: `GET /student/clubs`
- **Description**: Search for clubs with optional filters
- **Query Parameters**:
  - `campus` (optional): Filter by campus (e.g., `"Boston"`)
  - `gradLevel` (optional): Filter by grad level (e.g., `"undergrad"`)
- **Example**: `GET /student/clubs?campus=Boston&gradLevel=undergrad`
- **Response**: JSON array of club objects

#### Get Student Applications

- **Endpoint**: `GET /student/applications/<studentID>`
- **Description**: Retrieve all applications for a specific student
- **Example**: `GET /student/applications/1`
- **Response**: JSON array of application objects ordered by submission date (newest first)

#### Create Application

- **Endpoint**: `POST /student/applications`
- **Description**: Submit a new application to a club
- **Request Body**:

  ```json
  {
    "studentID": 1,
    "clubID": 3,
    "dateSubmitted": "2025-12-02"
  }
  ```

- **Response**: JSON object with `message` and `applicationID`

#### Update Application

- **Endpoint**: `PUT /student/applications/<applicationID>`
- **Description**: Update the status of an existing application
- **Request Body**:

  ```json
  {
    "status": "withdrawn"
  }
  ```

- **Response**: JSON object with success message

#### Delete Application

- **Endpoint**: `DELETE /student/applications/<applicationID>`
- **Description**: Delete/withdraw an application
- **Example**: `DELETE /student/applications/1`
- **Response**: JSON object with success message

### Streamlit Pages

The following Streamlit pages are located in `app/src/pages/`:

- **`50_alex_Home.py`**: The student home page with navigation buttons to access all student features.
- **`51_alex_clubs.py`**: Search and filter clubs by campus and grad level. Displays results in a dataframe.
- **`52_alex_applications.py`**: View all applications for a specific student ID. Shows application details including status and submission date.
- **`53_alex_new_application.py`**: Submit a new application to a club. Requires student ID, club ID, and submission date.
- **`54_alex_update_application.py`**: Update the status of an existing application. Uses a dropdown to select from valid status options (`pending`, `withdrawn`, `accepted`, `rejected`).
- **`55_alex_delete_application.py`**: Delete/withdraw an application. Includes a confirmation checkbox to prevent accidental deletions.

### Testing the Student API

You can test the API endpoints using `curl`:

```bash
# Search clubs
curl http://localhost:4000/student/clubs

# Search with filters
curl "http://localhost:4000/student/clubs?campus=Boston&gradLevel=undergrad"

# Get student applications
curl http://localhost:4000/student/applications/1

# Create application
curl -X POST http://localhost:4000/student/applications \
  -H "Content-Type: application/json" \
  -d '{"studentID": 1, "clubID": 3, "dateSubmitted": "2025-12-02"}'

# Update application
curl -X PUT http://localhost:4000/student/applications/1 \
  -H "Content-Type: application/json" \
  -d '{"status": "withdrawn"}'

# Delete application
curl -X DELETE http://localhost:4000/student/applications/1
```

### Accessing Student Pages

The student pages can be accessed directly via URL or through the Streamlit app navigation. All pages include proper error handling and user feedback for successful operations and errors.

---

## Analyst Functionality (Willow)

The data analyst persona functionality allows an analyst to view data about club searches, applications, categories, demographics, and events. 

### API Routes

The data analyst blueprint (`api/backend/willow/willow_routes.py`) provides 5 REST API endpoints:

#### Get data about searches

- **Endpoint**: `GET /clubs/searches`
- **Description**: show all clubs and the number of searches they have
- **Response**: table of clubs and number of searches they have

#### Get data about applications

- **Endpoint**: `GET /clubs/applications`
- **Description**: show all clubs and the number of applications they have
- **Response**: table of all clubs and the number of applications they have

#### Get data about club categories

- **Endpoint**: `GET /clubs/categories`
- **Description**: show all clubs and the categories they are a part of
- **Response**: table with all clubs and their respective categories

#### Get data about a certain club's demographics

- **Endpoint**: `GET /clubs/<int:clubID>/demographics`
- **Description**: shows all students belonging to this specific club and their demographic information
- **Query Parameters**:
  - `clubID` (required): input a club ID to see demographic information about members of that club
- **Example**: `GET /clubs/1/demographics`
- **Response**: table of all students in a particular club and their demographic information

#### Get data about event attendees

- **Endpoint**: `GET /events/attendees`
- **Description**: compare an event's number of students registered with the host club's number of members
- **Response**: table with club, event, numregistered and club members

### Streamlit Pages

The following Streamlit pages are located in `app/src/pages/`:

- **`40_willow_home.py`**: The data analyst home page with navigation buttons to access all data analyst features.
- **`41_willow_searches.py`**: See data about clubs and their searches.
- **`42_willow_applications.py`**: See data about clubs and their applications. 
- **`43_willow_categories.py`**: See data about clubs and their categories.
- **`44_willow_demographics.py`**: see data about students in a particular club and their demographic information.
- **`45_willow_attendees.py`**: see data about an event, the number registered for the event, the host club and host club's number of members.

### Testing the Data Analyst API

You can test the API endpoints using `curl`:

```bash
# data about searches
curl http://localhost:4000/clubs/searches

# data about applications
curl "http://localhost:4000/clubs/applications"

# data about club categories
curl http://localhost:4000/clubs/categories

# data about a club's demographics
curl  http://localhost:4000/clubs/<int:clubID>/demographics

# Update application
curl  http://localhost:4000/events/attendees
```

### Accessing Data Analyst Pages

The data analyst pages can be accessed directly via URL or through the Streamlit app navigation. All pages include proper error handling and user feedback for successful operations and errors.

---

## E-Board Functionality (Kaitlyn)

The E-Board persona functionality allows executive board members to manage their club's operations, including reviewing member applications, managing club members and their tiers, creating and managing events, viewing event registrations, and handling event capacity.

### API Routes

The E-Board blueprint (`api/backend/kaitlyn/kaitlyn_routes.py`) provides 13 REST API endpoints:

#### Get Club Applications

- **Endpoint**: `GET /clubs/<clubID>/applications`
- **Description**: Retrieve all pending applications for a specific club
- **Example**: `GET /clubs/5/applications`
- **Response**: JSON array of pending application objects with student details ordered by submission date

#### Get Interested Students

- **Endpoint**: `GET /clubs/<clubID>/interested-students`
- **Description**: View all students with pending applications (alternative view)
- **Example**: `GET /clubs/5/interested-students`
- **Response**: JSON array of pending applicants with contact information

#### Update Application Status

- **Endpoint**: `PUT /applications/<applicationID>`
- **Description**: Update the status of a club application (Accepted/Rejected/Pending)
- **Request Body**:
```json
  {
    "status": "Accepted"
  }
```

- **Response**: JSON object with success message

#### Delete Application

- **Endpoint**: `DELETE /applications/<applicationID>`
- **Description**: Remove a processed application from the system
- **Example**: `DELETE /applications/15`
- **Response**: JSON object with success message

#### Get Club Members

- **Endpoint**: `GET /clubs/<clubID>/members`
- **Description**: View all current members of a specific club
- **Example**: `GET /clubs/5/members`
- **Response**: JSON array of member objects with student details, member type, and join dates

#### Get Member Details

- **Endpoint**: `GET /clubs/<clubID>/members/<memberID>`
- **Description**: Get detailed information about a specific club member including tier
- **Example**: `GET /clubs/5/members/42`
- **Response**: JSON object with complete member details

#### Update Member Tier

- **Endpoint**: `PUT /clubs/<clubID>/members/<memberID>`
- **Description**: Update a member's tier (e.g., general to active member)
- **Request Body**:
```json
  {
    "memberType": "active"
  }
```

- **Response**: JSON object with success message

#### Get Club Events

- **Endpoint**: `GET /clubs/<clubID>/events`
- **Description**: View all upcoming events hosted by a specific club
- **Example**: `GET /clubs/5/events`
- **Response**: JSON array of event objects with registration counts and spots remaining

#### Create Club Event

- **Endpoint**: `POST /clubs/<clubID>/events`
- **Description**: Create a new event for the club
- **Request Body**:
```json
  {
    "name": "Club Meeting",
    "date": "2025-12-15",
    "startTime": "18:00:00",
    "endTime": "19:30:00",
    "location": "Student Center Room 201",
    "description": "Monthly club meeting",
    "capacity": 50,
    "tierRequirement": "Open"
  }
```

- **Response**: JSON object with success message and new eventID

#### Get Event Details

- **Endpoint**: `GET /events/<eventID>`
- **Description**: Get detailed information about a specific event including capacity
- **Example**: `GET /events/12`
- **Response**: JSON object with complete event details

#### Update Event

- **Endpoint**: `PUT /events/<eventID>`
- **Description**: Update event details (capacity, tier requirements, mark as full, etc.)
- **Request Body**:
```json
  {
    "isFull": 1,
    "tierRequirement": "active"
  }
```

- **Response**: JSON object with success message

#### Archive Event

- **Endpoint**: `DELETE /events/<eventID>`
- **Description**: Archive a past event (soft delete)
- **Example**: `DELETE /events/12`
- **Response**: JSON object with success message

#### Get Event Registrations

- **Endpoint**: `GET /events/<eventID>/registered-students`
- **Description**: View all students registered for a specific event
- **Example**: `GET /events/12/registered-students`
- **Response**: JSON array of registered student objects with contact information

### Streamlit Pages

The following Streamlit pages are located in `app/src/pages/`:

- **`20_Kaitlyn_EBoard_Home.py`**: The e-board home page with navigation buttons to access all six e-board management features.
- **`21_Interested_Students.py`**: View all students with pending applications to the club, including their contact information and submission dates.
- **`22_Event_Signups.py`**: View detailed registration lists for specific club events, showing which students have signed up.
- **`23_Manage_Events.py`**: Manage all club events - view upcoming events, update event details, set capacity, mark events as full, and archive past events.
- **`24_Member_Tiers.py`**: Update member tiers for club members (e.g., promote general members to active members).
- **`25_Applications.py`**: View and process pending member applications - accept or reject applicants and remove processed applications.
- **`26_Create_Event.py`**: Create new events for the club with details including date, time, location, capacity, and tier requirements.

### Testing the E-Board API

You can test the API endpoints using `curl`:
```bash
# Get club applications
curl http://localhost:4000/clubs/5/applications

# Get interested students
curl http://localhost:4000/clubs/5/interested-students

# Update application status
curl -X PUT http://localhost:4000/applications/15 \
  -H "Content-Type: application/json" \
  -d '{"status": "Accepted"}'

# Delete application
curl -X DELETE http://localhost:4000/applications/15

# Get club members
curl http://localhost:4000/clubs/5/members

# Get specific member details
curl http://localhost:4000/clubs/5/members/42

# Update member tier
curl -X PUT http://localhost:4000/clubs/5/members/42 \
  -H "Content-Type: application/json" \
  -d '{"memberType": "active"}'

# Get club events
curl http://localhost:4000/clubs/5/events

# Create new event
curl -X POST http://localhost:4000/clubs/5/events \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Club Meeting",
    "date": "2025-12-15",
    "startTime": "18:00:00",
    "endTime": "19:30:00",
    "location": "Student Center Room 201",
    "description": "Monthly club meeting",
    "capacity": 50,
    "tierRequirement": "Open"
  }'

# Get event details
curl http://localhost:4000/events/12

# Update event
curl -X PUT http://localhost:4000/events/12 \
  -H "Content-Type: application/json" \
  -d '{"isFull": 1, "tierRequirement": "active"}'

# Archive event
curl -X DELETE http://localhost:4000/events/12

# Get event registrations
curl http://localhost:4000/events/12/registered-students
```

### Accessing E-Board Pages

The e-board pages can be accessed directly via URL or through the Streamlit app navigation. All pages include proper error handling, confirmation dialogs for sensitive operations, and user feedback for successful actions and errors.

---

---
---


---
## System Administrator (Elizabeth)


The system administrator functionality allows system administrators of ClubHub to search for administrator permissions, create new administrative permissions, view all system updates, change an update status, create new notifications for users, view system errors, and delete system errors once solved.


### API Routes


The Administrator blueprint (`api/backend/Elizabeth/Elizabeth_routes.py`) provides 17 REST API endpoints under the `/Elizabeth` URL prefix:


#### Get All Errors


- **Endpoint**: `GET /error`
- **Description**: Find all errors on the application
- **Query Parameters**:
 - `error_type` (optional): Filter by error type (e.g., `"syntax error"`)
 - `time_reported` (optional): Filter by time the error was reported (e.g., `"Fri, 06 Dec 2024 12:45:47 GMT"`)
- **Example**: `GET /error/error_type=syntax error&time_reported=Fri, 06 Dec 2024 12:45:47 GMT`
- **Response**: JSON array of errors


#### Get a Specific Error


- **Endpoint**: `GET /error/<int:errorId>`
- **Description**: retrieve details of a specific error by its ID
- **Example**: `GET /error/1`
- **Response**: details of the error with the specified ID


#### Delete an Error


- **Endpoint**: `DELETE /error/<int:errorId>`
- **Description**: remove an error once it has been solved
- **Example**: `DELETE /error/1`
- **Response**: confirmation message with deleted error ID


#### Get all Updated


- **Endpoint**: `GET /update`
- **Description**: retrieve all system updates with optional filtering by update type, status, and scheduled time
- **Response**: table of all updates matching the filter criteria


#### Get a Specific Update


- **Endpoint**: `GET /update/<int:update_id>`
- **Description**: retrieve details of a specific update by its ID
- **Example**: `GET /update/1`
- **Response**: details of the update with the specified ID


#### Change an Update Status


- **Endpoint**: `PUT /update/<int:update_id>`
- **Description**: modify the status and other fields of an existing update
- **Example**: `PUT /update/1`
- **Response**: confirmation message


#### Create a Notification


- **Endpoint**: `POST /updateNotifications/notification`
- **Description**: create a new notification for an update
- **Response**: confirmation message with new notification ID


#### Get all Admin Permissions


- **Endpoint**: `GET /adminPermissions`
- **Description**: retrieve all administrator permissions with optional filtering by admin ID and permission
- **Response**: table of all admin permissions matching the filter criteria


#### Get a specific Admin Permission


- **Endpoint**: `GET /adminPermissions/<int:admin_id>`
- **Description**: retrieve permissions for a specific administrator
- **Example**: `GET /adminPermissions/1`
- **Response**: permissions for the specified admin


#### Update Admin Permissions


- **Endpoint**: `PUT /adminPermissions/<int:admin_id>`
- **Description**: modify the permissions of a particular administrator
- **Example**: `PUT /adminPermissions/1`
- **Response**: confirmation message


#### Create Admin Permissions


- **Endpoint**: `POST /adminPermissions`
- **Description**: create permissions for a new administrator
- **Response**: confirmation message with admin ID


#### Get all E-board Contacts


- **Endpoint**: `GET /adminContact`
- **Description**: retrieve all e-board contact information with optional filtering by e-board ID and admin ID
- **Response**: table of all e-board contacts matching the filter criteria


#### Get a Specific E-Board Contact


- **Endpoint**: `GET /adminContact/<int:eboard_id>`
- **Description**: retrieve contact information for a specific club e-board
- **Example**: `GET /adminContact/1`
- **Response**: contact information for the specified e-board


#### Get all Sytem Errors


- **Endpoint**: `GET /system/error`
- **Description**: retrieve all system errors with optional filtering by system ID and error type
- **Response**: table of all system errors matching the filter criteria


#### Get a Specific System Error


- **Endpoint**: `GET /system/error/<int:errorId>`
- **Description**: retrieve details of a specific system network error
- **Example**: `GET /system/error/1`
- **Response**: details of the system error with the specified ID


#### Delete a System Error


- **Endpoint**: `DELETE /system/error/<int:errorId>`
- **Description**: remove a particular error a system network has
- **Example**: `DELETE /system/error/1`
- **Response**: confirmation message with deleted error ID


### Streamlit Pages


The following Streamlit pages are located in `app/src/pages/`:


- **`60_administrator_home.py`**: The administrator home page with navigation buttons to access all admin features.
- **`61_admin_permissions_directory.py`**: Search and filter admin permissions by permission. Displays admin permission information and option to create a permission.
- **`62_update_directory.py`**: Search and filter all updates by status, update type, and update availability. S Every update has the option to view full details and return to home, change the status of an update, and create a notification for users via that update.
- **`63_error_directory.py`**: Search and filter errors by error type and time reported. Displays basic information and option to delete the error once solved.
- **`64_network_system_error_directory.py`**: Search and filter network errors by system ID and error type. Displays basic information and option to delete the error once solved.
- **`65_change_update_status.py`**: Update the status of a specific update via drop down menu for new status. This page is accessible via the update directory Includes a confirmation message.
- **`66_create_admin_permissions.py`**: Creates a new admin permission. Access via the admin permission directory or the home page
- **`67_create_notifications.py`**: Create a new notification for users about updates, errors, or general system details.
- **`68_eboard_admin_contact.py`**: View eboard information so administrators can switch pages to view specific eboard details as a point of contact.


### Testing the Admin API


You can test the API endpoints using `curl`:


```bash
# Get all admin permissions
curl http://localhost:4000/Elizabeth/adminPermissions


# Filter by specific permission
curl "http://localhost:4000/Elizabeth/adminPermissions?permission=full_access"


# Get permissions for a specific admin
curl http://localhost:4000/Elizabeth/adminPermissions/1


# Create new admin permissions
curl -X POST http://localhost:4000/Elizabeth/adminPermissions \
 -H "Content-Type: application/json" \
 -d '{"adminID": 5, "permission": "limited_access"}'


# Update admin permissions
curl -X PUT http://localhost:4000/Elizabeth/adminPermissions/1 \
 -H "Content-Type: application/json" \
 -d '{"permission": "guest_access"}'


# Get all updates
curl http://localhost:4000/Elizabeth/update


# Filter by status
curl "http://localhost:4000/Elizabeth/update?updateStatus=scheduled"


# Filter by update type
curl "http://localhost:4000/Elizabeth/update?updateType=Bug_fix"


# Filter by multiple parameters
curl "http://localhost:4000/Elizabeth/update?updateStatus=completed&updateType=API_integration"


# Get a specific update
curl http://localhost:4000/Elizabeth/update/1


# Update an update's status
curl -X PUT http://localhost:4000/Elizabeth/update/1 \
 -H "Content-Type: application/json" \
 -d '{"updateStatus": "in_progress", "startTime": "2025-12-08 10:00:00"}'


# Get all errors
curl http://localhost:4000/Elizabeth/error


# Filter by error type
curl "http://localhost:4000/Elizabeth/error?errorType=database_error"


# Filter by time reported
curl "http://localhost:4000/Elizabeth/error?timeReported=2025-12-08 10:30:00"


# Filter by multiple parameters
curl "http://localhost:4000/Elizabeth/error?errorType=logic_error&timeReported=2025-12-07 14:00:00"


# Get a specific error
curl http://localhost:4000/Elizabeth/error/1


# Delete an error
curl -X DELETE http://localhost:4000/Elizabeth/error/1


# Get all system errors
curl http://localhost:4000/Elizabeth/system/error


# Filter by system ID
curl "http://localhost:4000/Elizabeth/system/error?systemID=101"


# Filter by error type
curl "http://localhost:4000/Elizabeth/system/error?errorType=network"


# Filter by multiple parameters
curl "http://localhost:4000/Elizabeth/system/error?systemID=101&errorType=hardware"


# Get a specific system error
curl http://localhost:4000/Elizabeth/system/error/1


# Delete a system error
curl -X DELETE http://localhost:4000/Elizabeth/system/error/1


# Get all updates
curl http://localhost:4000/Elizabeth/update


# Get a specific update
curl http://localhost:4000/Elizabeth/update/1


# Update status only
curl -X PUT http://localhost:4000/Elizabeth/update/1 \
 -H "Content-Type: application/json" \
 -d '{"updateStatus": "in_progress"}'


# Update multiple fields
curl -X PUT http://localhost:4000/Elizabeth/update/1 \
 -H "Content-Type: application/json" \
 -d '{"updateStatus": "completed", "updateType": "Database_migration", "availability": "completed"}'


# Create new admin permissions
curl -X POST http://localhost:4000/Elizabeth/adminPermissions \
 -H "Content-Type: application/json" \
 -d '{"adminID": 5, "permission": "write_only"}'


# Create permissions with full access
curl -X POST http://localhost:4000/Elizabeth/adminPermissions \
 -H "Content-Type: application/json" \
 -d '{"adminID": 6, "permission": "full_access"}'


# Verify the created permission
curl http://localhost:4000/Elizabeth/adminPermissions/5
`
# Create a new notification
curl -X POST http://localhost:4000/Elizabeth/updateNotifications/notification \
 -H "Content-Type: application/json" \
 -d '{"notification": "System maintenance scheduled for tonight", "updateID": 1}'


# Create notification with detailed message
curl -X POST http://localhost:4000/Elizabeth/updateNotifications/notification \
 -H "Content-Type: application/json" \
 -d '{"notification": "Security update will be applied. Expected downtime: 2 hours.", "updateID": 2}'


# Get all e-board contacts
curl http://localhost:4000/Elizabeth/adminContact


# Filter by e-board ID
curl "http://localhost:4000/Elizabeth/adminContact?eboardID=1"


# Filter by admin ID
curl "http://localhost:4000/Elizabeth/adminContact?adminID=2"


# Filter by both parameters
curl "http://localhost:4000/Elizabeth/adminContact?eboardID=1&adminID=2"


# Get a specific e-board contact
curl http://localhost:4000/Elizabeth/adminContact/1
```


### Accessing Administrator Pages


The administrator pages can be accessed directly via URL or through the Streamlit app navigation. All pages include proper error handling and user feedback for successful operations and errors.

