import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

st.title("Admin Permissions Directory")

# API endpoint
API_URL = "http://web-api:4000/adminPermissions"

# Create filter columns
col1 = st.columns(1)[0]

# Get unique values for filters from the API
try:
    response = requests.get(API_URL)
    if response.status_code == 200:
        admin_permissions = response.json()

        # Extract unique values for filters
        permissions = sorted(list(set(ap["permission"] for ap in admin_permissions)))

        # Create filters
        with col1:
            selected_permission = st.selectbox("Filter by Permission", ["All"] + permissions)

        # Build query parameters
        params = {}
        if selected_permission != "All":
            params["permission"] = selected_permission

        # Get filtered data
        filtered_response = requests.get(API_URL, params=params)
        if filtered_response.status_code == 200:
            filtered_permissions = filtered_response.json()

            # Display results count
            st.write(f"Found {len(filtered_permissions)} Admin Permissions")

            # Create expandable rows for each admin permission
            for ap in filtered_permissions:
                with st.expander(f"Admin ID: {ap['adminID']} - Permission: {ap['permission']}"):
                    col1, col2 = st.columns(2)

                    with col1:
                        st.write("**Admin Information**")
                        st.write(f"**Admin ID:** {ap['adminID']}")
                        st.write(f"**Permission:** {ap['permission']}")

                    with col2:
                        st.write("**Actions**")
                        st.write("Manage this admin's permissions")

                    # Add button
                    button_col1 = st.columns(1)
                    
                    with button_col1:
                        if st.button(f"Create Permission", key=f"change_{ap['adminID']}"):
                            st.session_state["selected_admin_id"] = ap["adminID"]
                            st.switch_page("pages/66_create_admin_permissions.py")
                    
    

    else:
        st.error("Failed to fetch Admin Permissions data from the API")

except requests.exceptions.RequestException as e:
    st.error(f"Error connecting to the API: {str(e)}")
    st.info("Please ensure the API server is running on http://web-api:4000")