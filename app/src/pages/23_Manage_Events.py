import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')
SideBarLinks()

st.title("Manage Events")
st.write('')

try:
    response = requests.get('http://api:4000/api/clubs/1/events')
    
    if response.status_code == 200:
        events = response.json()
        
        if events:
            for event in events:
                with st.expander(f"{event['eventName']} - {event['date']}"):
                    st.write(f"Location: {event['location']}")
                    st.write(f"Capacity: {event['numRegistered']}/{event['capacity']}")
                    st.write(f"Tier: {event['tierRequirement']}")
                    st.write(f"Status: {'Full' if event['isFull'] else 'Open'}")
                    
                    st.write('')
                    
                    # Mark as full button
                    if not event['isFull']:
                        if st.button("Mark as Full", key=f"full_{event['eventID']}"):
                            try:
                                requests.put(f"http://api:4000/api/events/{event['eventID']}", 
                                           json={"isFull": 1})
                                st.success("Marked as full!")
                                st.rerun()
                            except:
                                st.error("Error updating event")
                    
                    # Archive event button
                    if st.button("Archive Event", key=f"archive_{event['eventID']}"):
                        try:
                            requests.delete(f"http://api:4000/api/events/{event['eventID']}")
                            st.success("Event archived!")
                            st.rerun()
                        except:
                            st.error("Error archiving event")
        else:
            st.info("No events found")
    else:
        st.error("Error fetching events")
        
except:
    st.error("Could not connect to database")