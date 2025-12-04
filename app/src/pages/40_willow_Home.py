import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks

st.set_page_config(layout = 'wide')

# Show appropriate sidebar links for the role of the currently logged in user
SideBarLinks()

st.title(f"Welcome Data Analyst, {st.session_state['first_name']}.")
st.write('')
st.write('')
st.write('### What would you like to do today?')

if st.button('View club searches', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/41_willow_searches.py')

if st.button('View club applications', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/42/willow_applications.py')

if st.button('View club categories', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/43_willow_categories.py')

if st.button('View Club Demographics', 
             type='primary',
             use_container_width=True):
  st.switch_page('pages/44_willow_demographics.py')

if st.button("View Classification Demo",
             type='primary',
             use_container_width=True):
  st.switch_page('pages/45_willow_attendees.py')
  