import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')
SideBarLinks()

st.title("Students Signed Up for Event")
st.write('')

try:
    # Use a specific event ID (change to match your test data)
    response = requests.get('http://api:4000/api/events/1/registered-students')
    
    if response.status_code == 200:
        students = response.json()
        
        if students:
            st.dataframe(students)
        else:
            st.info("No students signed up at this time")
    else:
        st.error("Error fetching signed up students")
        
except:
    st.error("Could not connect to database")