import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

st.title("Update Directory")

# API endpoint
API_URL = "http://api:4000/Elizabeth/update"

# Create filter columns
col1, col2, col3 = st.columns(3)

# Get unique values for filters from the API
try:
    response = requests.get(API_URL)
    if response.status_code == 200:
        updates = response.json()

        # Extract unique values for filters
        update_statuses = sorted(list(set(update["updateStatus"] for update in updates)))
        update_types = sorted(list(set(update["updateType"] for update in updates)))
        availabilities = sorted(list(set(update["availability"] for update in updates)))

        # Create filters
        with col1:
            selected_status = st.selectbox("Filter by Status", ["All"] + update_statuses)

        with col2:
            selected_type = st.selectbox("Filter by Update Type", ["All"] + update_types)

        with col3:
            selected_availability = st.selectbox("Filter by Availability", ["All"] + availabilities)

        # Build query parameters
        params = {}
        if selected_status != "All":
            params["updateStatus"] = selected_status
        if selected_type != "All":
            params["updateType"] = selected_type
        if selected_availability != "All":
            params["availability"] = selected_availability

        # Get filtered data
        filtered_response = requests.get(API_URL, params=params)
        if filtered_response.status_code == 200:
            filtered_updates = filtered_response.json()

            # Display results count
            st.write(f"Found {len(filtered_updates)} Updates")

            # Create expandable rows for each update
            for update in filtered_updates:
                with st.expander(f"Update ID: {update['updateID']} - {update['updateStatus']} ({update['updateType']})"):
                    col1, col2 = st.columns(2)

                    with col1:
                        st.write("**Basic Information**")
                        st.write(f"**Update ID:** {update['updateID']}")
                        st.write(f"**Status:** {update['updateStatus']}")
                        st.write(f"**Type:** {update['updateType']}")
                        st.write(f"**Availability:** {update['availability']}")

                    with col2:
                        st.write("**Timing Information**")
                        st.write(f"**Admin ID:** {update['adminID']}")
                        st.write(f"**Scheduled Time:** {update['scheduledTime']}")
                        st.write(f"**Start Time:** {update['startTime']}")
                        st.write(f"**End Time:** {update['endTime']}")

                    # Add buttons
                    button_col1, button_col2, button_col3 = st.columns(3)
                    
                    with button_col1:
                        if st.button(f"View Full Details", key=f"view_{update['updateID']}"):
                            st.session_state["selected_update_id"] = update["updateID"]
                            st.switch_page("pages/60_administrator_home.py")
                    
                    with button_col2:
                        if st.button(f"Change Status", key=f"change_{update['updateID']}"):
                            st.session_state["selected_update_id"] = update["updateID"]
                            st.switch_page("pages/65_change_update_status.py")

                    with button_col3:
                        if st.button(f"Create Notification for Users", key=f"notify_{update['updateID']}"):
                            st.session_state["selected_update_id"] = update["updateID"]
                            st.switch_page("pages/67_create_notification.py")


    else:
        st.error("Failed to fetch Update data from the API")

except requests.exceptions.RequestException as e:
    st.error(f"Error connecting to the API: {str(e)}")
    st.info("Please ensure the API server is running on http://web-api:4000")