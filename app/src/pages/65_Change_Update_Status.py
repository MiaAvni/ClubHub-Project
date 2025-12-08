import streamlit as st
import requests
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

st.title("Change Update Status")

# API endpoint
API_URL = "http://api:4000/Elizabeth/update"

# Check if update ID was passed
if "selected_update_id" not in st.session_state:
    st.error("No update selected. Please go back to the Update Directory.")
    if st.button("Return to Update Directory"):
        st.switch_page("pages/62_update_directory.py")
else:
    update_id = st.session_state["selected_update_id"]
    
    # Get the current update details
    try:
        response = requests.get(f"{API_URL}/{update_id}")
        if response.status_code == 200:
            update = response.json()
            
            st.subheader(f"Update ID: {update_id}")
            st.write(f"**Current Status:** {update['updateStatus']}")
            st.write(f"**Type:** {update['updateType']}")
            st.write(f"**Availability:** {update['availability']}")
            
            st.divider()
            
            # Get all updates to extract unique statuses from the database
            all_updates_response = requests.get(API_URL)
            if all_updates_response.status_code == 200:
                all_updates = all_updates_response.json()
                
                # Extract unique statuses from database
                all_statuses = sorted(list(set(u["updateStatus"] for u in all_updates)))
                
                # Remove the current status from options
                available_statuses = [status for status in all_statuses if status != update['updateStatus']]
                
                # Form to update the status
                with st.form("update_status_form"):
                    st.subheader("Update Information")
                    
                    new_status = st.selectbox(
                        "New Status",
                        options=available_statuses
                    )
                    
                    new_type = st.text_input("Update Type", value=update['updateType'])
                    new_availability = st.text_input("Availability", value=update['availability'])
                    
                    submitted = st.form_submit_button("Update Status")
                    
                    if submitted:
                        # Prepare the data
                        update_data = {
                            "updateStatus": new_status,
                            "updateType": new_type,
                            "availability": new_availability
                        }
                        
                        try:
                            # Send PUT request
                            put_response = requests.put(f"{API_URL}/{update_id}", json=update_data)
                            
                            if put_response.status_code == 200:
                                st.success("Update status changed successfully!")
                                st.session_state["update_success"] = True
                            else:
                                st.error(f"Failed to update: {put_response.json().get('error', 'Unknown error')}")
                        
                        except requests.exceptions.RequestException as e:
                            st.error(f"Error connecting to the API: {str(e)}")
                
                
                if st.session_state.get("update_success", False):
                    if st.button("Return to Update Directory"):
                        st.session_state["update_success"] = False
                        st.switch_page("pages/62_update_directory.py")
                
                
                if st.button("Cancel and Return"):
                    st.switch_page("pages/62_update_directory.py")
                    
            else:
                st.error("Failed to fetch available statuses")
        
        else:
            st.error("Failed to fetch update details")
    
    except requests.exceptions.RequestException as e:
        st.error(f"Error connecting to the API: {str(e)}")