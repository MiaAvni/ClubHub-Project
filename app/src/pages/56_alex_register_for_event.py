import streamlit as st
import requests
from modules.nav import SideBarLinks

SideBarLinks()

st.title("Register for an Event")

student_id = st.text_input("Student ID", placeholder="Enter your student ID number")
event_id = st.text_input("Event ID", placeholder="Enter the event ID number")

# Optional: Show event details if eventID is provided
if event_id and event_id.strip():
    try:
        event_id_int = int(event_id.strip())
        # Try to get event details from Kaitlyn's endpoint to show event info
        try:
            event_response = requests.get(f'http://api:4000/eboardmember/events/{event_id_int}')
            if event_response.status_code == 200:
                event_data = event_response.json()
                st.info(f"**Event:** {event_data.get('name', 'N/A')}  \n"
                       f"**Date:** {event_data.get('date', 'N/A')}  \n"
                       f"**Location:** {event_data.get('location', 'N/A')}  \n"
                       f"**Capacity:** {event_data.get('numRegistered', 0)}/{event_data.get('capacity', 'N/A')} registered")
        except:
            pass  # If we can't get event details, that's okay
    except ValueError:
        pass  # Invalid event ID format, will be caught in validation

if st.button("Register for Event", type="primary"):
    # Validate student ID input
    if not student_id or not student_id.strip():
        st.error("Please enter a Student ID")
        st.stop()
    
    try:
        student_id_int = int(student_id.strip())
        if student_id_int < 1:
            st.error("Student ID must be a positive number")
            st.stop()
    except ValueError:
        st.error("Student ID must be a valid number")
        st.stop()
    
    # Validate event ID input
    if not event_id or not event_id.strip():
        st.error("Please enter an Event ID")
        st.stop()
    
    try:
        event_id_int = int(event_id.strip())
        if event_id_int < 1:
            st.error("Event ID must be a positive number")
            st.stop()
    except ValueError:
        st.error("Event ID must be a valid number")
        st.stop()
    
    # Register for the event
    # Note: This endpoint needs to be created in the API at /student/events
    url = "http://api:4000/student/events"
    
    body = {
        "studentID": student_id_int,
        "eventID": event_id_int
    }

    try:
        response = requests.post(url, json=body)
        response.raise_for_status()  # Raise an exception for bad status codes
        
        result = response.json()
        st.success(f"✅ Successfully registered for event!")
        st.write(f"**Message:** {result.get('message', 'Registration successful')}")
        
    except requests.exceptions.HTTPError as e:
        if hasattr(e.response, 'status_code'):
            if e.response.status_code == 400:
                try:
                    error_data = e.response.json()
                    st.error(f"Validation Error: {error_data.get('error', 'Invalid input')}")
                except:
                    st.error(f"Validation Error: {str(e)}")
            elif e.response.status_code == 404:
                st.error("Event or Student not found. Please check your IDs.")
            elif e.response.status_code == 409:
                st.warning("You are already registered for this event.")
            else:
                st.error(f"HTTP Error {e.response.status_code}: {str(e)}")
        else:
            st.error(f"HTTP Error: {str(e)}")
    except requests.exceptions.RequestException as e:
        st.error(f"Could not connect to the API: {str(e)}")
        st.info("💡 **Note:** Make sure the API endpoint `/student/events` (POST) is implemented in the backend.")
    except Exception as e:
        st.error(f"An error occurred: {str(e)}")

