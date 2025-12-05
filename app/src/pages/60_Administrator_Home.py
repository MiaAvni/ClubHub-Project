import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks

st.set_page_config(layout = 'wide')

# Show appropriate sidebar links for the role of the currently logged in user
SideBarLinks()

st.title(f"Welcome System Administrator, {st.session_state['first_name']}.")
st.write('')
st.write('')
st.write('### What would you like to do today?')

st.write('#### Admin Management')
col1, col2 = st.columns(2)

with col1:
    if st.button('View Admin Permissions Directory', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/61_admin_permissions_directory.py')

with col2:
    if st.button('Create Admin Permissions', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/66_create_admin_permissions.py')

st.write('#### System Updates')
col3, col4 = st.columns(2)

with col3:
    if st.button('View Update Directory', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/62_update_directory.py')

with col4:
    if st.button('Create Notification', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/67_create_notification.py')

st.write('#### Error Management')
col5, col6 = st.columns(2)

with col5:
    if st.button('View Error Directory', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/error_directory.py')

with col6:
    if st.button('View Network System Error Directory', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/network_system_error_directory.py')

st.write('#### E-board Contact')
if st.button('View E-board Admin Contact Directory', 
             type='primary',
             use_container_width=True):
    st.switch_page('pages/68_eboard_admin_contact.py')