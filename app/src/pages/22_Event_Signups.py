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
    # Fetch all club events
    events_response = requests.get('http://api:4000/eboardmember/clubs/1/events')
    
    if events_response.status_code == 200:
        events = events_response.json()
        
        if events and not isinstance(events, dict):
            # Create dropdown for event selection
            event_options = {f"{event['eventName']} - {event['date']}": event['eventID'] for event in events}
            selected_event = st.selectbox("Select an event:", options=list(event_options.keys()))
            
            if selected_event:
                event_id = event_options[selected_event]
                
                # Fetch students for selected event
                response = requests.get(f'http://api:4000/eboardmember/events/{event_id}/registered-students')
                
                if response.status_code == 200:
                    students = response.json()
                    
                    if students:
                        st.dataframe(students)
                    else:
                        st.info("No students signed up at this time")
                else:
                    st.error("Error fetching signed up students")
        else:
            st.info("No events available")
    else:
        st.error("Error fetching events")
        
except:
    st.error("Could not connect to database")