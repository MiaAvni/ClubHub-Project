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

## Persona 4: [Team Member Name]

> [!NOTE]
> This section will be completed by [Team Member Name]. Please add your persona name, API routes, Streamlit pages, and testing instructions here.

---

---

## Original Template Documentation (Reference)

> [!TIP]
> The following sections contain the original template documentation. Team members can refer to this when writing their persona sections to maintain consistency with the project structure and formatting guidelines.

### Original Template Introduction

This is a template repo for Dr. Fontenot's Fall 2025 CS 3200 Course Project.

It includes most of the infrastructure setup (containers), sample databases, and example UI pages. Explore it fully and ask questions!

### Original Template RBAC Documentation

The code in this project demonstrates how to implement a simple RBAC system in Streamlit but without actually using user authentication (usernames and passwords). The Streamlit pages from the original template repo are split up among 3 roles - Political Strategist, USAID Worker, and a System Administrator role (this is used for any sort of system tasks such as re-training ML model, etc.). It also demonstrates how to deploy an ML model.

Wrapping your head around this will take a little time and exploration of this code base. Some highlights are below.

#### Getting Started with the RBAC (Template Reference)

1. We need to turn off the standard panel of links on the left side of the Streamlit app. This is done through the `app/src/.streamlit/config.toml` file. So check that out. We are turning it off so we can control directly what links are shown.
1. Then I created a new python module in `app/src/modules/nav.py`. When you look at the file, you will see that there are functions for basically each page of the application. The `st.sidebar.page_link(...)` adds a single link to the sidebar. We have a separate function for each page so that we can organize the links/pages by role.
1. Next, check out the `app/src/Home.py` file. Notice that there are 3 buttons added to the page and when one is clicked, it redirects via `st.switch_page(...)` to that Roles Home page in `app/src/pages`. But before the redirect, I set a few different variables in the Streamlit `session_state` object to track role, first name of the user, and that the user is now authenticated.
1. Notice near the top of `app/src/Home.py` and all other pages, there is a call to `SideBarLinks(...)` from the `app/src/nav.py` module. This is the function that will use the role set in `session_state` to determine what links to show the user in the sidebar.
1. The pages are organized by Role. Pages that start with a `0` are related to the _Political Strategist_ role. Pages that start with a `1` are related to the _USAID worker_ role. And, pages that start with a `2` are related to The _System Administrator_ role.

### Template Example: Persona Documentation Format

When documenting your persona, follow this structure (as shown in the Student Functionality section above):

1. **Section Header**: Use `## Persona Name: [Name]`
2. **Introduction**: Brief description of what the persona can do
3. **API Routes**: Document all REST API endpoints with:
   - Endpoint path and HTTP method
   - Description
   - Query parameters or request body (if applicable)
   - Example requests
   - Response format
4. **Streamlit Pages**: List all pages with brief descriptions
5. **Testing**: Provide `curl` examples for testing API endpoints
6. **Accessing Pages**: Note how pages can be accessed
