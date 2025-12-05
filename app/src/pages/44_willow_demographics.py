import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

if 'form_key_counter' not in st.session_state:
    st.session_state.form_key_counter = 0

# Create a form for clubID details 
with st.form(f"add_clubID_{st.session_state.form_key_counter}"):
    st.subheader("ClubID Information")

    # Required fields
    clubID = st.text_input("ClubID: *")

    # Form submission button
    submitted = st.form_submit_button("Confirm ClubID")

    if submitted:
        # Validate required fields
        if not all([clubID]):
            st.error("Please fill in all required fields marked with *")


st.title(f"Demographics Data For Club {clubID}")

demos = requests.get(f'http://api:4000/clubs/{clubID}/demographics').json()

try:
  st.dataframe(demos)
except:
  st.write('Could not connect to database to retrieve searches')