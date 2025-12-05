import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')
SideBarLinks()

st.title("Students Interested in Joining Club")
st.write('')

try:
    # Fixed: use actual club ID and correct URL path
    response = requests.get('http://api:4000/api/clubs/1/interested-students')
    
    if response.status_code == 200:
        interested_students = response.json()
        
        if interested_students:
            st.dataframe(interested_students)
        else:
            st.info("No interested students at this time")
    else:
        st.error("Error fetching interested students")
        
except:
    st.error("Could not connect to database to retrieve interested students")