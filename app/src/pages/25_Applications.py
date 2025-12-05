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
    response = requests.get('http://api:4000/eboardmember/clubs/1/applications')
    
    if response.status_code == 200:
        applications = response.json()
        
        if applications and not isinstance(applications, dict):
            # Create dropdown for application selection
            app_options = {f"{app['firstName']} {app['lastName']} - {app['major']} ({app['status']})": app['applicationID'] 
                          for app in applications}
            selected_app = st.selectbox("Select an application to review:", options=list(app_options.keys()))
            
            if selected_app:
                app_id = app_options[selected_app]
                # Find the selected application data
                app = next(a for a in applications if a['applicationID'] == app_id)
                
                st.write(f"**Email:** {app['email']}")
                st.write(f"**Major:** {app['major']}")
                st.write(f"**Grad Year:** {app['gradYear']}")
                st.write(f"**Date Submitted:** {app['dateSubmitted']}")
                st.write(f"**Status:** {app['status']}")
                
                st.write('')
                
                col1, col2, col3 = st.columns(3)
                
                if app['status'] == 'Pending':
                    with col1:
                        if st.button("✅ Approve"):
                            try:
                                update_response = requests.put(
                                    f"http://api:4000/eboardmember/applications/{app['applicationID']}", 
                                    json={"status": "Accepted"}
                                )
                                if update_response.status_code == 200:
                                    st.success("Application approved!")
                                    st.rerun()
                                else:
                                    st.error("Error approving application")
                            except:
                                st.error("Error approving application")
                    
                    with col2:
                        if st.button("❌ Deny"):
                            try:
                                update_response = requests.put(
                                    f"http://api:4000/eboardmember/applications/{app['applicationID']}", 
                                    json={"status": "Rejected"}
                                )
                                if update_response.status_code == 200:
                                    st.success("Application denied")
                                    st.rerun()
                                else:
                                    st.error("Error denying application")
                            except:
                                st.error("Error denying application")
                
                with col3:
                    if st.button("🗑️ Delete"):
                        try:
                            delete_response = requests.delete(
                                f"http://api:4000/eboardmember/applications/{app['applicationID']}"
                            )
                            if delete_response.status_code == 200:
                                st.success("Application deleted")
                                st.rerun()
                            else:
                                st.error("Error deleting application")
                        except:
                            st.error("Error deleting application")
        else:
            st.info("No applications found")
    else:
        st.error("Error fetching applications")
        
except:
    st.error("Could not connect to database")