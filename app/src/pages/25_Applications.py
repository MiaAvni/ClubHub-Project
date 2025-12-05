import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')
SideBarLinks()

st.title("View & Process Applications")
st.write('')

try:
    response = requests.get('http://api:4000/api/clubs/1/applications')
    
    if response.status_code == 200:
        applications = response.json()
        
        for app in applications:
            with st.expander(f"{app['firstName']} {app['lastName']} - {app['status']}"):
                st.write(f"Email: {app['email']}")
                st.write(f"Major: {app['major']}")
                st.write(f"Grad Year: {app['gradYear']}")
                st.write(f"Date Submitted: {app['dateSubmitted']}")
                st.write(f"Status: {app['status']}")
                
                st.write('')
                
                if app['status'] == 'Pending':
                    # Approve button
                    if st.button("Approve", key=f"approve_{app['applicationID']}"):
                        try:
                            requests.put(
                                f"http://api:4000/api/applications/{app['applicationID']}", 
                                json={"status": "Accepted"}
                            )
                            st.success("Application approved!")
                            st.rerun()
                        except:
                            st.error("Error approving application")
                    
                    # Deny button
                    if st.button("Deny", key=f"deny_{app['applicationID']}"):
                        try:
                            requests.put(
                                f"http://api:4000/api/applications/{app['applicationID']}", 
                                json={"status": "Rejected"}
                            )
                            st.success("Application denied")
                            st.rerun()
                        except:
                            st.error("Error denying application")
                else:
                    # Delete button for processed applications
                    if st.button("Delete", key=f"delete_{app['applicationID']}"):
                        try:
                            requests.delete(f"http://api:4000/api/applications/{app['applicationID']}")
                            st.success("Application deleted")
                            st.rerun()
                        except:
                            st.error("Error deleting application")
    else:
        st.error("Error fetching applications")
        
except:
    st.error("Could not connect to database")