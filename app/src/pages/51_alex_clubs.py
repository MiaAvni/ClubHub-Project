import streamlit as st
import requests
from modules.nav import SideBarLinks

SideBarLinks()

st.title("Search for Clubs")

st.write("Use the filters below if you want to narrow your search.")

campus = st.text_input("Campus (optional, e.g., 'Boston')")
gradLevel = st.text_input("Grad Level (optional, e.g., 'undergrad')")

if st.button("Search Clubs", type="primary"):
    # Build URL with query params
    base_url = "http://api:4000/student/clubs"
    params = {}
    
    if campus:
        params["campus"] = campus
    
    if gradLevel:
        params["gradLevel"] = gradLevel
    
    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()  # Raise an exception for bad status codes
        
        data = response.json()
        
        if data:
            st.success(f"Found {len(data)} club(s)")
            st.dataframe(data)
        else:
            st.info("No clubs found matching your criteria.")
            
    except requests.exceptions.RequestException as e:
        st.error(f"Could not connect to the API: {str(e)}")
    except Exception as e:
        st.error(f"An error occurred: {str(e)}")
