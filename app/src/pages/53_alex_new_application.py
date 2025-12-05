import streamlit as st
import requests
from modules.nav import SideBarLinks

SideBarLinks()

st.title("Submit a New Application")

student_id = st.number_input("Student ID", min_value=1, step=1)
club_id = st.number_input("Club ID", min_value=1, step=1)
date_submitted = st.date_input("Date Submitted")

if st.button("Submit Application", type="primary"):
    url = "http://api:4000/student/applications"
    
    body = {
        "studentID": int(student_id),
        "clubID": int(club_id),
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
