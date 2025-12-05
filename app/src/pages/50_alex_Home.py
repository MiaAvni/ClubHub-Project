# pages/50_alex_Home.py

import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')

# Show appropriate sidebar links for the role of the currently “logged in” user
SideBarLinks()

st.title(f"Welcome Student {st.session_state['first_name']}.")
st.write('')
st.write('')
st.write('### What would you like to do today?')

if st.button('Search for Clubs',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/51_alex_clubs.py')

if st.button('View My Applications',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/52_alex_applications.py')

if st.button('Submit a New Application',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/53_alex_new_application.py')

if st.button('Update an Application Status',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/54_alex_update_application.py')

if st.button('Withdraw / Delete an Application',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/55_alex_delete_application.py')
