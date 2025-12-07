import streamlit as st
import requests
from modules.nav import SideBarLinks

SideBarLinks()

st.title("Submit a New Application")

student_id = st.text_input("Student ID", placeholder="Enter student ID number")
club_id = st.text_input("Club ID", placeholder="Enter club ID number")
date_submitted = st.date_input("Date Submitted")

if st.button("Submit Application", type="primary"):
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
    
    # Validate club ID input
    if not club_id or not club_id.strip():
        st.error("Please enter a Club ID")
        st.stop()
    
    try:
        club_id_int = int(club_id.strip())
        if club_id_int < 1:
            st.error("Club ID must be a positive number")
            st.stop()
    except ValueError:
        st.error("Club ID must be a valid number")
        st.stop()
    
    url = "http://api:4000/student/applications"
    
    body = {
        "studentID": student_id_int,
        "clubID": club_id_int,
        "dateSubmitted": str(date_submitted)
    }

    try:
        response = requests.post(url, json=body)
        response.raise_for_status()  # Raise an exception for bad status codes
        
        result = response.json()
        st.success(f"✅ Application created successfully!")
        st.write(f"**Application ID:** {result.get('applicationID', 'N/A')}")
        st.write(f"**Message:** {result.get('message', '')}")
        
    except requests.exceptions.HTTPError as e:
        if response.status_code == 400:
            error_data = response.json()
            st.error(f"Validation Error: {error_data.get('error', 'Invalid input')}")
        else:
            st.error(f"HTTP Error {response.status_code}: {str(e)}")
    except requests.exceptions.RequestException as e:
        st.error(f"Could not connect to the API: {str(e)}")
    except Exception as e:
        st.error(f"An error occurred: {str(e)}")
