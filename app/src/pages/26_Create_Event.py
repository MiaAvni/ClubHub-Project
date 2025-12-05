import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks
from datetime import datetime 

SideBarLinks()

st.write("## Create a New Club Event")

with st.form("Create a New Club Event"):
    event_name = st.text_input("Event Name")
    date = st.date_input("Event Date")
    start_time = st.time_input("Start Time")
    end_time = st.time_input("End Time")
    location = st.text_input("Location")
    description = st.text_area("Description")
    capacity = st.number_input("Capacity", min_value=1, step=1)
    tier_requirement = st.selectbox("Tier Requirement", 
        ["Open", "Active Members Only", "Accepted Members Only", "Executive Board Only"])    
    submit_button = st.form_submit_button("Create Event")

    if submit_button:

        start_datetime = datetime.combine(date, start_time)
        end_datetime = datetime.combine(date, end_time)
        

        data = {}
        data['name'] = event_name
        data['date'] = date.isoformat()
        data['startTime'] = start_time.isoformat()
        data['endTime'] = end_time.isoformat()
        data['location'] = location
        data['description'] = description
        data['capacity'] = capacity
        data['tierRequirement'] = tier_requirement
        st.write(data)

        try:
            response = requests.post('http://api:4000/api/clubs/1/events', json=data)
            if response.status_code == 201:
                st.success("Event created successfully!")
            else:
                st.error("Error creating event")
        except:
            st.error("Connection error")