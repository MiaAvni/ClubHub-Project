import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

st.title("Error Directory")

# API endpoint
API_URL = "http://web-api:4000/error"

# Create filter columns
col1, col2 = st.columns(2)

# Get unique values for filters from the API
try:
    response = requests.get(API_URL)
    if response.status_code == 200:
        errors = response.json()

        # Extract unique values for filters
        error_types = sorted(list(set(error["errorType"] for error in errors)))
        time_reported_list = sorted(list(set(error["timeReported"] for error in errors)))

        # Create filters
        with col1:
            selected_error_type = st.selectbox("Filter by Error Type", ["All"] + error_types)

        with col2:
            selected_time = st.selectbox("Filter by Time Reported", ["All"] + time_reported_list)

        # Build query parameters
        params = {}
        if selected_error_type != "All":
            params["errorType"] = selected_error_type
        if selected_time != "All":
            params["timeReported"] = selected_time

        # Get filtered data
        filtered_response = requests.get(API_URL, params=params)
        if filtered_response.status_code == 200:
            filtered_errors = filtered_response.json()

            # Display results count
            st.write(f"Found {len(filtered_errors)} Errors")

            # Create expandable rows for each error
            for error in filtered_errors:
                with st.expander(f"{error['errorType']} ({error['timeReported']})"):
                    col1, col2 = st.columns(2)

                    with col1:
                        st.write("**Basic Information**")
                        st.write(f"**Error Type:** {error['errorType']}")
                        st.write(f"**Time Reported:** {error['timeReported']}")

                    with col2:
                        st.write("**Additional Information**")
                        st.write(f"**Error ID:** {error['errorID']}")

                    # Add delete button (DELETE)
                    if st.button(f"Mark as Solved & Delete", key=f"delete_{error['errorID']}"):
                        delete_response = requests.delete(f"{API_URL}/{error['errorID']}")
                        if delete_response.status_code == 200:
                            st.success("Error deleted successfully!")
                            st.rerun()
                        else:
                            st.error("Failed to delete error")

    else:
        st.error("Failed to fetch Error data from the API")

except requests.exceptions.RequestException as e:
    st.error(f"Error connecting to the API: {str(e)}")
    st.info("Please ensure the API server is running on http://web-api:4000")