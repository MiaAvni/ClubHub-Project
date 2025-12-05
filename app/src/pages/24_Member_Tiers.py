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
    response = requests.get('http://api:4000/eboardmember/clubs/1/members')
    
    if response.status_code == 200:
        members = response.json()
        
        if members and not isinstance(members, dict):
            # Create dropdown for member selection
            member_options = {f"{member['firstName']} {member['lastName']} - {member['memberType']}": member['studentID'] 
                            for member in members}
            selected_member = st.selectbox("Select a member to manage:", options=list(member_options.keys()))
            
            if selected_member:
                student_id = member_options[selected_member]
                # Find the selected member data
                member = next(m for m in members if m['studentID'] == student_id)
                
                st.write(f"**Email:** {member['email']}")
                st.write(f"**Major:** {member['major']}")
                st.write(f"**Grad Year:** {member['gradYear']}")
                st.write(f"**Current Tier:** {member['memberType']}")
                st.write(f"**Joined:** {member['joinDate']}")
                
                st.write('')
                
                # Update tier
                new_tier = st.selectbox(
                    "New Tier",
                    ["General Member", "Active Member", "E-Board"]
                )
                
                if st.button("Update Tier"):
                    try:
                        update_response = requests.put(
                            f"http://api:4000/eboardmember/clubs/1/members/{member['studentID']}", 
                            json={"memberType": new_tier}
                        )
                        if update_response.status_code == 200:
                            st.success(f"Updated to {new_tier}!")
                            st.rerun()
                        else:
                            st.error("Error updating member tier")
                    except:
                        st.error("Error updating member tier")
        else:
            st.info("No members found")
    else:
        st.error("Error fetching members")
        
except:
    st.error("Could not connect to database")