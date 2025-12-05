import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

# Initialize sidebar
SideBarLinks()

st.title("Club Categories Data")

categories = requests.get('http://api:4000/clubs/categories').json()

try:
  st.dataframe(categories)
except:
  st.write('Could not connect to database to retrieve searches')