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
    response = requests.get('http://api:4000/eboardmember/clubs/1/events')
    
    if response.status_code == 200:
        events = response.json()
        
        if events and not isinstance(events, dict):
            # Create dropdown for event selection
            event_options = {f"{event['eventName']} - {event['date']}": event['eventID'] for event in events}
            selected_event = st.selectbox("Select an event to manage:", options=list(event_options.keys()))
            
            if selected_event:
                event_id = event_options[selected_event]
                # Find the selected event data
                event = next(e for e in events if e['eventID'] == event_id)
                
                st.write(f"**Location:** {event['location']}")
                st.write(f"**Time:** {event['startTime']} - {event['endTime']}")
                st.write(f"**Capacity:** {event['numRegistered']}/{event['capacity']} ({event['spotsRemaining']} spots remaining)")
                st.write(f"**Tier Requirement:** {event['tierRequirement']}")
                st.write(f"**Status:** {'Full' if event['isFull'] else 'Open'}")
                st.write(f"**Description:** {event['description']}")
                
                st.write('')
                
                col1, col2 = st.columns(2)
                
                with col1:
                    # Mark as full button
                    if not event['isFull']:
                        if st.button("Mark as Full"):
                            try:
                                update_response = requests.put(
                                    f"http://api:4000/eboardmember/events/{event['eventID']}", 
                                    json={"isFull": 1}
                                )
                                if update_response.status_code == 200:
                                    st.success("Marked as full!")
                                    st.rerun()
                                else:
                                    st.error("Error updating event")
                            except:
                                st.error("Error updating event")
                
                with col2:
                    # Archive event button
                    if st.button("Archive Event"):
                        try:
                            delete_response = requests.delete(
                                f"http://api:4000/eboardmember/events/{event['eventID']}"
                            )
                            if delete_response.status_code == 200:
                                st.success("Event archived!")
                                st.rerun()
                            else:
                                st.error("Error archiving event")
                        except:
                            st.error("Error archiving event")
        else:
            st.info("No events found")
    else:
        st.error("Error fetching events")
        
except:
    st.error("Could not connect to database")