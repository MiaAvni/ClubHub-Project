import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

st.title("Event Attendees Data")

searches = requests.get('http://api:4000/events/attendees').json()

try:
  st.dataframe(searches)
except:
  st.write('Could not connect to database to retrieve searches')