import streamlit as st
import requests
from modules.nav import SideBarLinks

SideBarLinks()

st.title("Update Application Status")

application_id = st.number_input("Application ID", min_value=1, step=1)
new_status = st.selectbox(
    "New Status",
    options=["pending", "withdrawn", "accepted", "rejected"],
    help="Select the new status for your application"
)

if st.button("Update Application", type="primary"):
    if not new_status:
        st.warning("Please select a status.")
    else:
        url = f"http://api:4000/student/applications/{application_id}"
        
        body = {"status": new_status}

        try:
            response = requests.put(url, json=body)
            response.raise_for_status()  # Raise an exception for bad status codes
            
            result = response.json()
            st.success(f"✅ Application updated successfully!")
            st.write(f"**Message:** {result.get('message', '')}")
            
        except requests.exceptions.HTTPError as e:
            if response.status_code == 404:
                st.error("Application not found.")
            elif response.status_code == 400:
                error_data = response.json()
                st.error(f"Validation Error: {error_data.get('error', 'Invalid input')}")
            else:
                st.error(f"HTTP Error {response.status_code}: {str(e)}")
        except requests.exceptions.RequestException as e:
            st.error(f"Could not connect to the API: {str(e)}")
        except Exception as e:
            st.error(f"An error occurred: {str(e)}")
