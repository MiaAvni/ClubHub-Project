# Idea borrowed from https://github.com/fsmosca/sample-streamlit-authenticator

# This file has function to add certain functionality to the left side bar of the app

import streamlit as st

# ----------------------------eboard--------------------------
def EBoardNav():
    st.sidebar.page_link("pages/20_EBoard_Home.py", label="E-Board Home", icon='👥')

def interestedstudents():
    st.sidebar.page_link("pages/21_Interested_Students.py", label="Interested Students", icon='🎓')

def eventsignups():
    st.sidebar.page_link("pages/22_Event_Signups.py", label="Event Signups", icon='📋')
    
def manageevents():
    st.sidebar.page_link("pages/23_Manage_Events.py", label="Manage Events", icon='📅')

def seeapplications():
    st.sidebar.page_link("pages/25_Applications.py", label="Applications", icon='📝')

def createevent():
    st.sidebar.page_link("pages/26_Create_Event.py", label="Create Event", icon='➕')


#### ------------------------ home ------------------------
def HomeNav():
    st.sidebar.page_link("Home.py", label="Home", icon="🏠")


def AboutPageNav():
    st.sidebar.page_link("pages/30_About.py", label="About", icon="🧠")


#### ------------------------ data analyst willow  ------------------------
def DataAnalystHomeNav():
    st.sidebar.page_link(
        "pages/40_willow_home.py", label="Data Analyst Home"
    )


def SearchData():
    st.sidebar.page_link(
        "pages/41_willow_searches.py", label="Search Data"
    )


def AppsData():
    st.sidebar.page_link(
        "pages/42_willow_applications.py", label="Application Data"
    )

def CategoriesData():
    st.sidebar.page_link(
        "pages/43_willow_categories.py", label="Categories Data"
    )

def DemographicsData():
    st.sidebar.page_link(
        "pages/44_willow_demographics.py", label="Demographics Data"
    )

def AttendeesData():
    st.sidebar.page_link(
        "pages/45_willow_attendees.py", label="Attendees Data"
    )

#### ------------------------ student alex  ------------------------
def StudentHomeNav():
    st.sidebar.page_link(
        "pages/50_alex_Home.py", label="Student Home (Alex)", icon="📚"
    )


def AlexClubsNav():
    st.sidebar.page_link(
        "pages/51_alex_clubs.py", label="Find Clubs"
    )


def AlexApplicationsNav():
    st.sidebar.page_link(
        "pages/52_alex_applications.py", label="My Applications"
    )


def AlexNewApplicationNav():
    st.sidebar.page_link(
        "pages/53_alex_new_application.py", label="Submit Application"
    )


def AlexUpdateApplicationNav():
    st.sidebar.page_link(
        "pages/54_alex_update_application.py", label="Update Application"
    )


def AlexDeleteApplicationNav():
    st.sidebar.page_link(
        "pages/55_alex_delete_application.py", label="Delete Application"
    )

#### ------------------------ admin elizabeth  ------------------------
def adminNav():
    st.sidebar.page_link(
        "pages/60_Administrator_Home", label="Administrator Home (Elizabeth)"
    )

def adminpermissions():
    st.sidebar.page_link(
        "pages/61_Admin_Permissions_Directory", label="Administrator Permissions Directory"
    )
def adminupdatedirectory():
    st.sidebar.page_link(
        "pages/62_Update_Directory", label="Update Directory"
    )

def adminpermissions():
    st.sidebar.page_link(
        "pages/61_Admin_Permissions_Directory", label="Administrator Permissions Directory"
    )

def adminerrordirectory():
    st.sidebar.page_link(
        "pages/62_Update_Directory", label="Update Directory"
    )

def syserrordirectory():
    st.sidebar.page_link(
        "pages/64_Network_System_Error_Directory", label="System Error Directory"
    )

def changeupdatestatus():
    st.sidebar.page_link(
        "pages/65_Change_Update_Status", label="Change Update Status"
    )

def createpermissions():
    st.sidebar.page_link(
        "pages/66_Create_Admin_Permissions", label="Create Admin Permissions"
    )

def createnotification():
    st.sidebar.page_link(
        "pages/67_Create_Notifications", label="Create Notification"
    )
def admincontact():
    st.sidebar.page_link(
        "pages/68_Eboard_Admin_Contact", label="Contact Eboard"
    )

# --------------------------------Links Function -----------------------------------------------
def SideBarLinks(show_home=False):
    """
    This function handles adding links to the sidebar of the app based upon the logged-in user's role, which was put in the streamlit session_state object when logging in.
    """

    # add a logo to the sidebar always
    st.sidebar.image("assets/logo.svg", width=150)

    # If there is no logged in user, redirect to the Home (Landing) page
    if "authenticated" not in st.session_state:
        st.session_state.authenticated = False
        st.switch_page("Home.py")

    if show_home:
        # Show the Home page link (the landing page)
        HomeNav()

    # Show the other page navigators depending on the users' role.
    if st.session_state["authenticated"]:

        # if user is data analyst
        if st.session_state["role"] == "data_analyst":
            DataAnalystHomeNav()
            SearchData()
            AppsData()
            CategoriesData()
            DemographicsData()
            AttendeesData()

        # if user is eboard member
        if st.session_state["role"]  == "administrator":
            adminNav()
            adminpermissions()
            adminerrordirectory()
            syserrordirectory()
            changeupdatestatus()
            createpermissions()
            createnotification()
            admincontact()

        # if user is eboard member
        if st.session_state["role"] == "eboard":
            EBoardNav()
            interestedstudents()
            eventsignups()
            manageevents()
            seeapplication()
            createevent()

        # If the user is a student (Alex), show the student home link for easy navigation
        if st.session_state["role"] == "student":
            StudentHomeNav()
            AlexClubsNav()
            AlexApplicationsNav()
            AlexNewApplicationNav()
            AlexUpdateApplicationNav()
            AlexDeleteApplicationNav()


    # Always show the About page at the bottom of the list of links
    AboutPageNav()

    if st.session_state["authenticated"]:
        # Always show a logout button if there is a logged in user
        if st.sidebar.button("Logout"):
            del st.session_state["role"]
            del st.session_state["authenticated"]
            st.switch_page("Home.py")
