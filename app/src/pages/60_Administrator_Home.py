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
        st.switch_page('pages/Admin_Permissions_Directory.py')

with col2:
    if st.button('Create Admin Permissions', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/Create_Admin_Permissions.py')

st.write('#### System Updates')
col3, col4 = st.columns(2)

with col3:
    if st.button('View Update Directory', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/Update_Directory.py')

with col4:
    if st.button('Create Notification', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/Create_Notification.py')

st.write('#### Error Management')
col5, col6 = st.columns(2)

with col5:
    if st.button('View Error Directory', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/Error_Directory.py')

with col6:
    if st.button('View Network System Error Directory', 
                 type='primary',
                 use_container_width=True):
        st.switch_page('pages/Network_System_Error_Directory.py')

st.write('#### E-board Contact')
if st.button('View E-board Admin Contact Directory', 
             type='primary',
             use_container_width=True):
    st.switch_page('pages/Eboard_Admin_Contact.py')