import streamlit as st
import requests
from modules.nav import SideBarLinks

SideBarLinks()

st.title("My Applications")

student_id = st.number_input("Enter your Student ID", min_value=1, step=1)

if st.button("View My Applications", type="primary"):
    url = f"http://api:4000/student/applications/{student_id}"
    
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise an exception for bad status codes
        
        apps = response.json()
        
        if apps:
            st.success(f"Found {len(apps)} application(s)")
            st.dataframe(apps)
        else:
            st.info("You have no applications yet.")
            
    except requests.exceptions.HTTPError as e:
        if response.status_code == 404:
            st.warning("Student not found or no applications exist.")
        else:
            st.error(f"HTTP Error: {str(e)}")
    except requests.exceptions.RequestException as e:
        st.error(f"Could not connect to the API: {str(e)}")
    except Exception as e:
        st.error(f"An error occurred: {str(e)}")
