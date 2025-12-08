import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

st.title("Create Notification")

# Initialize session state for modal
if "show_success_modal" not in st.session_state:
    st.session_state.show_success_modal = False
if "success_notification_text" not in st.session_state:
    st.session_state.success_notification_text = ""
if "reset_form" not in st.session_state:
    st.session_state.reset_form = False
if "form_key_counter" not in st.session_state:
    st.session_state.form_key_counter = 0

# Define the success dialog function
@st.dialog("Success")
def show_success_dialog(notification_text):
    st.markdown(f"### Notification has been successfully created!")
    st.write(f"**Notification:** {notification_text}")
    
    # Create two buttons side by side
    col1, col2 = st.columns(2)
    
    with col1:
        if st.button("Return to Updates", use_container_width=True):
            st.session_state.show_success_modal = False
            st.session_state.success_notification_text = ""
            st.switch_page("pages/62_update_directory.py") 
    with col2:
        if st.button("Add Another Notification", use_container_width=True):
            st.session_state.show_success_modal = False
            st.session_state.success_notification_text = ""
            st.session_state.reset_form = True
            st.rerun()

# Handle form reset
if st.session_state.reset_form:
    st.session_state.form_key_counter += 1
    st.session_state.reset_form = False

# API endpoint
API_URL = "http://api:4000/Elizabeth/updateNotifications/notification"

# Create a form for notification details with dynamic key to force reset
with st.form(f"add_notification_form_{st.session_state.form_key_counter}"):
    st.subheader("Notification Information")

    # Required fields
    notification = st.text_area("Notification Message *", height=100)
    update_id = st.number_input("Update ID *", min_value=1, step=1)

    # Form submission button
    submitted = st.form_submit_button("Create Notification")

    if submitted:
        # Validate required fields
        if not all([notification, update_id]):
            st.error("Please fill in all required fields marked with *")
        else:
            # Prepare the data for API
            notification_data = {
                "notification": notification,
                "updateID": int(update_id),
            }

            try:
                # Send POST request to API
                response = requests.post(API_URL, json=notification_data)

                if response.status_code == 201:
                    # Store notification text and show modal
                    st.session_state.show_success_modal = True
                    st.session_state.success_notification_text = notification
                    st.rerun()
                else:
                    st.error(
                        f"Failed to create notification: {response.json().get('error', 'Unknown error')}"
                    )

            except requests.exceptions.RequestException as e:
                st.error(f"Error connecting to the API: {str(e)}")
                st.info("Please ensure the API server is running")

# Show success modal if notification was created successfully
if st.session_state.show_success_modal:
    show_success_dialog(st.session_state.success_notification_text)

# Add a button to return to the Home page
if st.button("Return to Home"):
    st.switch_page("pages/60_administrator_home.py")  