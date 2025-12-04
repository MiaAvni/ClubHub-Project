import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

st.title("Demographics Data")

demos = requests.get(f'http://api:4000/clubs/{clubID}/demographics').json()

try:
  st.dataframe(demos)
except:
  st.write('Could not connect to database to retrieve searches')