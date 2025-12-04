import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

st.title("Application Data")

applications = requests.get('http://api:4000/clubs/applications').json()

try:
  st.dataframe(applications)
except:
  st.write('Could not connect to database to retrieve searches')