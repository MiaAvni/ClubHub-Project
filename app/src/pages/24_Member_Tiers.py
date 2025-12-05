import logging
logger = logging.getLogger(__name__)
import streamlit as st
import requests
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')
SideBarLinks()

st.title("Manage Member Tiers")
st.write('')

try:
    response = requests.get('http://api:4000/api/clubs/1/members')
    
    if response.status_code == 200:
        members = response.json()
        
        for member in members:
            with st.expander(f"{member['firstName']} {member['lastName']} - {member['memberType']}"):
                st.write(f"Email: {member['email']}")
                st.write(f"Major: {member['major']}")
                st.write(f"Grad Year: {member['gradYear']}")
                st.write(f"Current Tier: {member['memberType']}")
                st.write(f"Joined: {member['joinDate']}")
                
                st.write('')
                
                # Update tier
                new_tier = st.selectbox(
                    "New Tier",
                    ["General Member", "Active Member", "E-Board"],
                    key=f"tier_{member['studentID']}"
                )
                
                if st.button("Update Tier", key=f"update_{member['studentID']}"):
                    try:
                        requests.put(
                            f"http://api:4000/api/clubs/1/members/{member['studentID']}", 
                            json={"memberType": new_tier}
                        )
                        st.success(f"Updated to {new_tier}!")
                        st.rerun()
                    except:
                        st.error("Error updating member tier")
    else:
        st.error("Error fetching members")
        
except:
    st.error("Could not connect to database")