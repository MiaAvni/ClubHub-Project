import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks

st.set_page_config(layout = 'wide')

# Show appropriate sidebar links for the role of the currently logged in user
SideBarLinks()

st.title(f"E-Board Member Dashboard {st.session_state['first_name']}.")
st.write('')
st.write('')
st.write('### What would you like to do today?')

if st.button('View Interested Students', 
             type='primary',
             use_container_width=True):
    st.switch_page('pages/21_Interested_Students.py')

if st.button('View Event Signups', 
             type='primary',
             use_container_width=True):
    st.switch_page('pages/22_Event_Signups.py')

if st.button('Manage Events', 
             type='primary',
             use_container_width=True):
    st.switch_page('pages/23_Manage_Events.py')

if st.button('Manage Member Tiers',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/24_Member_Tiers.py')

if st.button('View & Process Applications',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/25_Applications.py')

if st.button('Create New Event',
             type='primary',
             use_container_width=True):
    st.switch_page('pages/26_Create_Event.py')