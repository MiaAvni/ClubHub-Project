import streamlit as st
import requests
from modules.nav import SideBarLinks

SideBarLinks()

st.title("Delete / Withdraw Application")

st.warning("⚠️ This action cannot be undone. Please confirm before deleting.")

application_id = st.number_input("Application ID", min_value=1, step=1)

confirm_delete = st.checkbox("I confirm I want to delete this application")

if st.button("Delete Application", type="primary"):
    if not confirm_delete:
        st.error("Please confirm deletion by checking the checkbox.")
    else:
        url = f"http://api:4000/student/applications/{application_id}"

        try:
            response = requests.delete(url)
            response.raise_for_status()  # Raise an exception for bad status codes
            
            result = response.json()
            st.success(f"✅ Application deleted successfully!")
            st.write(f"**Message:** {result.get('message', '')}")
            
        except requests.exceptions.HTTPError as e:
            if response.status_code == 404:
                st.error("Application not found.")
            else:
                st.error(f"HTTP Error {response.status_code}: {str(e)}")
        except requests.exceptions.RequestException as e:
            st.error(f"Could not connect to the API: {str(e)}")
        except Exception as e:
            st.error(f"An error occurred: {str(e)}")
