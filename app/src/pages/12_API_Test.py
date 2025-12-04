import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from streamlit_extras.app_logo import add_logo
from modules.nav import SideBarLinks

SideBarLinks()

st.write("# Accessing a REST API from Within Streamlit")


searches = requests.get('http://api:4000/clubs/searches').json()

try:
  st.dataframe(searches)
except:
  st.write('Could not connect to database to retrieve searches')




# data = {} 
# try:
#   data = requests.get('http://web-api:4000/data').json()
# except:
#   st.write("**Important**: Could not connect to sample api, so using dummy data.")
#   data = {"a":{"b": "123", "c": "hello"}, "z": {"b": "456", "c": "goodbye"}}

# st.dataframe(data)
