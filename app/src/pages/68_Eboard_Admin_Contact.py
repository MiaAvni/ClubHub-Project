import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

st.title("E-board Contact Directory")

# API endpoint
API_URL = "http://web-api:4000/adminContact"

# Get all E-board contacts from the API
try:
    response = requests.get(API_URL)
    if response.status_code == 200:
        eboard_contacts = response.json()

        # Display results count
        st.write(f"Found {len(eboard_contacts)} E-board Contacts")

        # Create expandable rows for each E-board contact
        for contact in eboard_contacts:
            with st.expander(f"E-board ID: {contact['eboardID']} - Admin ID: {contact['adminID']}"):
                col1, col2 = st.columns(2)

                with col1:
                    st.write("**Contact Information**")
                    st.write(f"**E-board ID:** {contact['eboardID']}")
                    st.write(f"**Admin ID:** {contact['adminID']}")

                with col2:
                    st.write("**Actions**")
                    st.write("View related information")

                # Add buttons
                button_col1, button_col2 = st.columns(2)
                
                with button_col1:
                    if st.button(f"View E-board Details", key=f"eboard_{contact['eboardID']}"):
                        st.session_state["selected_eboard_id"] = contact["eboardID"]
                        st.switch_page("pages/20_EBoard_Home.py")
                
                with button_col2:
                    if st.button(f"View Admin Details", key=f"admin_{contact['adminID']}"):
                        st.session_state["selected_admin_id"] = contact["adminID"]
                        st.switch_page("pages/60_administrator_home.py")

    else:
        st.error("Failed to fetch E-board Contact data from the API")

except requests.exceptions.RequestException as e:
    st.error(f"Error connecting to the API: {str(e)}")
    st.info("Please ensure the API server is running on http://web-api:4000")