# ClubHub

ClubHub is a web application designed to help students discover and join clubs at their university. The application provides functionality for students to search for clubs, submit applications, and manage their club memberships. It also includes administrative and analytical features for club management and data analysis.

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


### Accessing Data Analyst Pages

The data analyst pages can be accessed directly via URL or through the Streamlit app navigation. All pages include proper error handling and user feedback for successful operations and errors.

---

## Persona 3: [Team Member Name]

> [!NOTE]
> This section will be completed by [Team Member Name]. Please add your persona name, API routes, Streamlit pages, and testing instructions here.

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
