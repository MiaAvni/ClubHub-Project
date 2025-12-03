-- ClubHub Database - DDL


DROP DATABASE IF EXISTS ClubHub;
CREATE DATABASE ClubHub;
USE ClubHub;


-- DROP TABLES (children first, then parents)


DROP TABLE IF EXISTS errorAdmin;
DROP TABLE IF EXISTS updateNotifications;
DROP TABLE IF EXISTS adminPermissions;
DROP TABLE IF EXISTS adminContact;
DROP TABLE IF EXISTS eboardPermissions;
DROP TABLE IF EXISTS eboardMember;
DROP TABLE IF EXISTS studentEvents;
DROP TABLE IF EXISTS clubEvents;
DROP TABLE IF EXISTS studentLeaves;
DROP TABLE IF EXISTS studentJoins;
DROP TABLE IF EXISTS searchFilters;
DROP TABLE IF EXISTS search;
DROP TABLE IF EXISTS application;
DROP TABLE IF EXISTS studentEmails;
DROP TABLE IF EXISTS clubCategories;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS `event`;
DROP TABLE IF EXISTS eboard;
DROP TABLE IF EXISTS club;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS error;
DROP TABLE IF EXISTS `update`;
DROP TABLE IF EXISTS administrator;
DROP TABLE IF EXISTS `system`;


-- CORE SYSTEM / ADMIN TABLES


CREATE TABLE `system` (
   systemID    INT AUTO_INCREMENT,
   version     VARCHAR(50),
   status      VARCHAR(50),
   network     VARCHAR(100),
   PRIMARY KEY (systemID)
);


CREATE TABLE administrator (
   adminID     INT AUTO_INCREMENT,
   systemID    INT,
   firstName   VARCHAR(50),
   lastName    VARCHAR(50),
   email       VARCHAR(100),
   PRIMARY KEY (adminID),
   FOREIGN KEY (systemID) REFERENCES `system`(systemID)
       ON DELETE RESTRICT
       ON UPDATE CASCADE
);


CREATE TABLE `update` (
   updateID        INT AUTO_INCREMENT,
   adminID         INT,
   updateStatus    VARCHAR(50),
   scheduledTime   DATETIME,
   startTime       DATETIME,
   endTime         DATETIME,
   updateType      VARCHAR(100),
   availability    VARCHAR(100),
   PRIMARY KEY (updateID),
   FOREIGN KEY (adminID) REFERENCES administrator(adminID)
       ON DELETE RESTRICT
       ON UPDATE CASCADE
);


CREATE TABLE error (
   errorID         INT AUTO_INCREMENT,
   systemID        INT,
   updateID        INT,
   errorType       VARCHAR(100),
   errorSolution   VARCHAR(500),
   timeReported    DATETIME,
   timeSolved      DATETIME,
   PRIMARY KEY (errorID),
   FOREIGN KEY (systemID) REFERENCES `system`(systemID)
       ON DELETE RESTRICT
       ON UPDATE CASCADE,
   FOREIGN KEY (updateID) REFERENCES `update`(updateID)
       ON DELETE SET NULL
       ON UPDATE CASCADE
);


CREATE TABLE updateNotifications (
   notification    VARCHAR(200),
   updateID        INT,
   PRIMARY KEY (notification, updateID),
   FOREIGN KEY (updateID) REFERENCES `update`(updateID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


CREATE TABLE errorAdmin (
   adminID     INT,
   errorID     INT,
   PRIMARY KEY (adminID, errorID),
   FOREIGN KEY (adminID) REFERENCES administrator(adminID)
       ON DELETE CASCADE
       ON UPDATE CASCADE,
   FOREIGN KEY (errorID) REFERENCES error(errorID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


CREATE TABLE adminPermissions (
   adminID     INT,
   permission  VARCHAR(100),
   PRIMARY KEY (adminID, permission),
   FOREIGN KEY (adminID) REFERENCES administrator(adminID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


-- CLUBS, EBOARDS, STUDENTS


CREATE TABLE club (
   clubID      INT AUTO_INCREMENT,
   name        VARCHAR(150),
   gradLevel   VARCHAR(50),      -- undergrad/grad/both
   campus      VARCHAR(50),
   description VARCHAR(500),
   numMembers  INT,
   numSearches INT,
   PRIMARY KEY (clubID)
);


CREATE TABLE eboard (
   eboardID        INT AUTO_INCREMENT,
   clubID          INT,
   president       VARCHAR(100),
   vicePresident   VARCHAR(100),
   secretary       VARCHAR(100),
   treasurer       VARCHAR(100),
   PRIMARY KEY (eboardID),
   FOREIGN KEY (clubID) REFERENCES club(clubID)
       ON DELETE RESTRICT
       ON UPDATE CASCADE
);


CREATE TABLE student (
   studentID       INT AUTO_INCREMENT,
   firstName       VARCHAR(50),
   lastName        VARCHAR(50),
   campus          VARCHAR(50),
   major           VARCHAR(100),
   minor           VARCHAR(100),
   age             INT,
   gender          VARCHAR(20),
   race            VARCHAR(50),
   gradYear        INT,
   PRIMARY KEY (studentID)
);


-- individual e-board members (links students to eboards/clubs)
CREATE TABLE eboardMember (
   eboardMemberID  INT AUTO_INCREMENT,
   studentID       INT,
   eboardID        INT,
   position        VARCHAR(50),
   PRIMARY KEY (eboardMemberID),
   FOREIGN KEY (studentID) REFERENCES student(studentID)
       ON DELETE CASCADE
       ON UPDATE CASCADE,


   FOREIGN KEY (eboardID) REFERENCES eboard(eboardID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


CREATE TABLE eboardPermissions (
   eboardMemberID  INT,
   permission      VARCHAR(100),
   PRIMARY KEY (eboardMemberID, permission),
   FOREIGN KEY (eboardMemberID) REFERENCES eboardMember(eboardMemberID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


CREATE TABLE adminContact (
   adminID     INT,
   eboardID    INT,
   PRIMARY KEY (adminID, eboardID),
   FOREIGN KEY (adminID) REFERENCES administrator(adminID)
       ON DELETE CASCADE
       ON UPDATE CASCADE,
   FOREIGN KEY (eboardID) REFERENCES eboard(eboardID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


-- CATEGORIES & CLUB-CATEGORY RELATIONSHIP


CREATE TABLE category (
   categoryID  INT AUTO_INCREMENT,
   name        VARCHAR(100),
   PRIMARY KEY (categoryID)
);


CREATE TABLE clubCategories (
   clubID      INT,
   categoryID  INT,
   PRIMARY KEY (clubID, categoryID),
   FOREIGN KEY (clubID) REFERENCES club(clubID)
       ON DELETE CASCADE
       ON UPDATE CASCADE,
   FOREIGN KEY (categoryID) REFERENCES category(categoryID)
       ON DELETE RESTRICT
       ON UPDATE CASCADE
);


-- STUDENT CONTACT, SEARCHES, MEMBERSHIP HISTORY


CREATE TABLE studentEmails (
   studentID   INT,
   email       VARCHAR(100),
   PRIMARY KEY (studentID, email),
   FOREIGN KEY (studentID) REFERENCES student(studentID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


CREATE TABLE search (
   searchID    INT AUTO_INCREMENT,
   studentID   INT,
   name        VARCHAR(200),      -- search text
   dateTime    DATETIME,
   PRIMARY KEY (searchID),
   FOREIGN KEY (studentID) REFERENCES student(studentID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


CREATE TABLE searchFilters (
   searchID    INT,
   filter      VARCHAR(100),
   PRIMARY KEY (searchID, filter),
   FOREIGN KEY (searchID) REFERENCES search(searchID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


CREATE TABLE studentJoins (
   studentID   INT,
   clubID      INT,
   joinDate    DATE,
   memberType  VARCHAR(50) DEFAULT 'General Member',
   PRIMARY KEY (studentID, clubID),
   FOREIGN KEY (studentID) REFERENCES student(studentID)
       ON DELETE CASCADE
       ON UPDATE CASCADE,
   FOREIGN KEY (clubID) REFERENCES club(clubID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


CREATE TABLE studentLeaves (
   studentID   INT,
   clubID      INT,
   leaveDate   DATE,
   PRIMARY KEY (studentID, clubID),
   FOREIGN KEY (studentID) REFERENCES student(studentID)
       ON DELETE CASCADE
       ON UPDATE CASCADE,
   FOREIGN KEY (clubID) REFERENCES club(clubID)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);




-- EVENTS, APPLICATIONS, ATTENDANCE


CREATE TABLE `event` (
   eventID         INT AUTO_INCREMENT,
   location        VARCHAR(200),
   date            DATE,
   description     VARCHAR(500),
   name            VARCHAR(150),
   startTime       DATETIME,
   endTime         DATETIME,
   capacity        INT,
   numRegistered   INT,
   isFull          INT,            -- 0 or 1
   isArchived      INT,            -- 0 or 1
   tierRequirement VARCHAR(50),
   PRIMARY KEY (eventID)
);


CREATE TABLE clubEvents (
   clubID      INT,
   eventID     INT,
   PRIMARY KEY (clubID, eventID),
   FOREIGN KEY (clubID) REFERENCES club(clubID)
       ON DELETE CASCADE
       ON UPDATE CASCADE,
   FOREIGN KEY (eventID) REFERENCES `event`(eventID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


CREATE TABLE studentEvents (
   studentID   INT,
   eventID     INT,
   PRIMARY KEY (studentID, eventID),
   FOREIGN KEY (studentID) REFERENCES student(studentID)
       ON DELETE CASCADE
       ON UPDATE CASCADE,
   FOREIGN KEY (eventID) REFERENCES `event`(eventID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);


CREATE TABLE application (
   applicationID   INT AUTO_INCREMENT,
   clubID          INT,
   studentID       INT,
   dateSubmitted   DATE,
   status          VARCHAR(50),
   PRIMARY KEY (applicationID),
   FOREIGN KEY (clubID) REFERENCES club(clubID)
       ON DELETE CASCADE
       ON UPDATE CASCADE,
   FOREIGN KEY (studentID) REFERENCES student(studentID)
       ON DELETE CASCADE
       ON UPDATE CASCADE
);

-- ClubHub Database

USE ClubHub;

-- 1. system
insert into `system` (systemID, version, status, network) values (1, '1.13', 'updating', 'NetGen');
insert into `system` (systemID, version, status, network) values (2, '2.9', 'rebooting', 'CyberSphere');
insert into `system` (systemID, version, status, network) values (3, '0.49', 'rebooting', 'ConnectX');
insert into `system` (systemID, version, status, network) values (4, '0.39', 'updating', 'ConnectX');
insert into `system` (systemID, version, status, network) values (5, '4.96', 'operational', 'TechConnect');
insert into `system` (systemID, version, status, network) values (6, '2.7.9', 'operational', 'NetGen');
insert into `system` (systemID, version, status, network) values (7, '0.9.0', 'standby', 'NetGen');
insert into `system` (systemID, version, status, network) values (8, '7.8', 'idle', 'NetPro');
insert into `system` (systemID, version, status, network) values (9, '8.49', 'standby', 'DataWave');
insert into `system` (systemID, version, status, network) values (10, '0.7.4', 'updating', 'WebWorks');
insert into `system` (systemID, version, status, network) values (11, '0.69', 'sleeping', 'ByteLink');
insert into `system` (systemID, version, status, network) values (12, '0.1.9', 'error', 'ByteLink');
insert into `system` (systemID, version, status, network) values (13, '7.63', 'standby', 'TechConnect');
insert into `system` (systemID, version, status, network) values (14, '6.58', 'idle', 'TechConnect');
insert into `system` (systemID, version, status, network) values (15, '6.2.8', 'busy', 'ConnectX');
insert into `system` (systemID, version, status, network) values (16, '9.59', 'offline', 'WebWorks');
insert into `system` (systemID, version, status, network) values (17, '0.96', 'operational', 'DataWave');
insert into `system` (systemID, version, status, network) values (18, '4.8.5', 'operational', 'CyberSphere');
insert into `system` (systemID, version, status, network) values (19, '3.5.9', 'busy', 'CyberSphere');
insert into `system` (systemID, version, status, network) values (20, '7.3.2', 'busy', 'LinkLogic');
insert into `system` (systemID, version, status, network) values (21, '0.4.6', 'maintenance', 'DataWave');
insert into `system` (systemID, version, status, network) values (22, '0.1.5', 'operational', 'NetGen');
insert into `system` (systemID, version, status, network) values (23, '8.48', 'maintenance', 'ByteLink');
insert into `system` (systemID, version, status, network) values (24, '8.63', 'idle', 'NetGen');
insert into `system` (systemID, version, status, network) values (25, '7.6.7', 'offline', 'ConnectX');
insert into `system` (systemID, version, status, network) values (26, '0.6.5', 'operational', 'WebWorks');
insert into `system` (systemID, version, status, network) values (27, '9.13', 'maintenance', 'TechConnect');
insert into `system` (systemID, version, status, network) values (28, '0.45', 'operational', 'ConnectX');
insert into `system` (systemID, version, status, network) values (29, '3.49', 'standby', 'InfoNet');
insert into `system` (systemID, version, status, network) values (30, '6.53', 'operational', 'InfoNet');
insert into `system` (systemID, version, status, network) values (31, '0.4.2', 'busy', 'LinkLogic');
insert into `system` (systemID, version, status, network) values (32, '0.2.4', 'error', 'ByteLink');
insert into `system` (systemID, version, status, network) values (33, '0.5.2', 'maintenance', 'InfoNet');
insert into `system` (systemID, version, status, network) values (34, '0.73', 'sleeping', 'WebWorks');
insert into `system` (systemID, version, status, network) values (35, '2.2', 'busy', 'WebWorks');
insert into `system` (systemID, version, status, network) values (36, '5.35', 'maintenance', 'WebWorks');
insert into `system` (systemID, version, status, network) values (37, '9.6', 'error', 'DataWave');
insert into `system` (systemID, version, status, network) values (38, '7.67', 'updating', 'InfoNet');
insert into `system` (systemID, version, status, network) values (39, '8.6', 'rebooting', 'WebWorks');
insert into `system` (systemID, version, status, network) values (40, '8.62', 'idle', 'NetGen');

-- 2. category
insert into category (categoryID, name) values (1, 'Computer Science');
insert into category (categoryID, name) values (2, 'Business');
insert into category (categoryID, name) values (3, 'Engineering');
insert into category (categoryID, name) values (4, 'Professional');
insert into category (categoryID, name) values (5, 'Gaming');
insert into category (categoryID, name) values (6, 'Media');
insert into category (categoryID, name) values (7, 'Academic');
insert into category (categoryID, name) values (8, 'Social');
insert into category (categoryID, name) values (9, 'Music');
insert into category (categoryID, name) values (10, 'Cultural');
insert into category (categoryID, name) values (11, 'Health & Wellness');
insert into category (categoryID, name) values (12, 'Environmental');
insert into category (categoryID, name) values (13, 'Sports');
insert into category (categoryID, name) values (14, 'Arts');
insert into category (categoryID, name) values (15, 'Community Service');
insert into category (categoryID, name) values (16, 'Pre-Professional');
insert into category (categoryID, name) values (17, 'Recreation');
insert into category (categoryID, name) values (18, 'Performing Arts');
insert into category (categoryID, name) values (19, 'Politics');
insert into category (categoryID, name) values (20, 'Science');
insert into category (categoryID, name) values (21, 'Technology');
insert into category (categoryID, name) values (22, 'Finance');
insert into category (categoryID, name) values (23, 'Marketing');
insert into category (categoryID, name) values (24, 'Consulting');
insert into category (categoryID, name) values (25, 'Entrepreneurship');
insert into category (categoryID, name) values (26, 'Data Science');
insert into category (categoryID, name) values (27, 'Design');
insert into category (categoryID, name) values (28, 'Photography');
insert into category (categoryID, name) values (29, 'Film');
insert into category (categoryID, name) values (30, 'Writing');
insert into category (categoryID, name) values (31, 'Leadership');
insert into category (categoryID, name) values (32, 'Diversity & Inclusion');
insert into category (categoryID, name) values (33, 'Volunteering');
insert into category (categoryID, name) values (34, 'International');
insert into category (categoryID, name) values (35, 'Networking');

-- 3. student
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (1, 'Midge', 'MacAless', 'Charlotte', 'Bioengineering', null, 25, 'Female', 'Hispanic or Latinx', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (2, 'Ari', 'Dimsdale', 'Oakland', 'Communications', 'Psychology', 21, 'Male', 'Other', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (3, 'Lexis', 'Clever', 'Oakland', 'Computer Science', 'Philosophy', 20, 'Polygender', 'Asian', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (4, 'Josefa', 'Duval', 'Seattle', 'Health Science', 'Biology', 24, 'Genderqueer', 'Other', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (5, 'Blayne', 'Tomas', 'Seattle', 'Business Administration', 'Sociology', 20, 'Male', 'Black or African American', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (6, 'Laurie', 'Dragonette', 'London', 'Mathematics', null, 24, 'Female', 'Mixed', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (7, 'Kanya', 'Trouncer', 'Charlotte', 'Bioengineering', null, 28, 'Female', 'Black or African American', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (8, 'Elliot', 'Shovell', 'Vancouver', 'Biology', null, 28, 'Male', 'Asian', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (9, 'Aile', 'Pawfoot', 'Boston', 'Economics', null, 22, 'Female', 'Middle Eastern', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (10, 'Ferguson', 'Rodie', 'Portland', 'Bioengineering', 'Biology', 24, 'Male', 'Middle Eastern', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (11, 'Dee dee', 'Grelak', 'Silicon Valley', 'Software Engineering', 'Economics', 21, 'Female', 'Middle Eastern', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (12, 'Darcy', 'Huntley', 'Boston', 'Business Administration', null, 21, 'Male', 'Mixed', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (13, 'Nicol', 'Reeder', 'Silicon Valley', 'Mathematics', null, 28, 'Male', 'Hispanic or Latinx', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (14, 'Guthry', 'Cheeke', 'Charlotte', 'Criminal Justice', 'Economics', 18, 'Male', 'Other', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (15, 'Aubry', 'Frotton', 'London', 'Finance', null, 22, 'Female', 'Black or African American', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (16, 'Finlay', 'Lethardy', 'Seattle', 'Software Engineering', 'Mathematics', 25, 'Male', 'Asian', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (17, 'Hatty', 'Boyle', 'Vancouver', 'Communications', 'Business Administration', 20, 'Female', 'White', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (18, 'Stacy', 'Cheese', 'Boston', 'Bioengineering', null, 27, 'Male', 'Mixed', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (19, 'Ira', 'Allcoat', 'Charlotte', 'Finance', 'Philosophy', 27, 'Male', 'Hispanic or Latinx', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (20, 'Fair', 'Nickell', 'London', 'Communications', 'Cybersecurity', 21, 'Male', 'Hispanic or Latinx', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (21, 'Elaina', 'Philipps', 'Portland', 'Chemical Engineering', 'Mathematics', 18, 'Female', 'Black or African American', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (22, 'Starla', 'Chorlton', 'Portland', 'Mechanical Engineering', null, 26, 'Female', 'Other', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (23, 'Kermy', 'Struthers', 'Portland', 'Computer Engineering', null, 20, 'Male', 'Mixed', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (24, 'Rici', 'Cornbell', 'London', 'Psychology', 'Economics', 26, 'Female', 'White', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (25, 'Celina', 'Suarez', 'London', 'Electrical Engineering', 'Cybersecurity', 27, 'Female', 'Asian', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (26, 'Eric', 'Hanney', 'Oakland', 'Cybersecurity', null, 24, 'Male', 'White', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (27, 'Vivianna', 'Cristofalo', 'Oakland', 'Economics', 'Computer Science', 19, 'Female', 'Middle Eastern', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (28, 'Ogden', 'Hallor', 'Silicon Valley', 'Entrepreneurship', 'Spanish', 27, 'Male', 'Hispanic or Latinx', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (29, 'Vita', 'Counihan', 'Portland', 'Bioengineering', null, 27, 'Female', 'Middle Eastern', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (30, 'Carroll', 'Grimsditch', 'Oakland', 'Health Science', 'Philosophy', 26, 'Female', 'Mixed', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (31, 'Mandy', 'De Few', 'Seattle', 'Mathematics', 'Sociology', 20, 'Female', 'Black or African American', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (32, 'Karim', 'Egginson', 'Charlotte', 'Economics', 'Communication Studies', 26, 'Male', 'White', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (33, 'Deane', 'Valente', 'Boston', 'Software Engineering', 'Design', 21, 'Bigender', 'Middle Eastern', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (34, 'Alexandros', 'Glanville', 'Silicon Valley', 'Computer Science', 'Philosophy', 25, 'Polygender', 'Other', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (35, 'Em', 'De Malchar', 'Vancouver', 'Biology', null, 18, 'Bigender', 'Hispanic or Latinx', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (36, 'Mickey', 'Dmiterko', 'Portland', 'Health Science', 'Psychology', 27, 'Non-binary', 'Other', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (37, 'Roddy', 'Martinelli', 'Oakland', 'Software Engineering', 'Spanish', 24, 'Male', 'Middle Eastern', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (38, 'Greg', 'Gimenez', 'London', 'Management', null, 19, 'Male', 'Asian', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (39, 'Ardelis', 'Norsworthy', 'Seattle', 'Management', 'Health Science', 27, 'Female', 'Black or African American', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (40, 'Alikee', 'Messingham', 'Charlotte', 'Chemical Engineering', 'Cybersecurity', 20, 'Female', 'Other', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (41, 'Greer', 'Verry', 'Portland', 'Mechanical Engineering', null, 26, 'Female', 'Middle Eastern', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (42, 'Willa', 'Tebboth', 'Oakland', 'Biology', 'Business Administration', 26, 'Female', 'Asian', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (43, 'Liliane', 'Rodgerson', 'Oakland', 'Biochemistry', 'Psychology', 25, 'Female', 'Asian', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (44, 'Garland', 'McKee', 'Vancouver', 'Communications', null, 23, 'Female', 'Other', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (45, 'Gar', 'Wenderott', 'Charlotte', 'Finance', 'Biology', 18, 'Male', 'Hispanic or Latinx', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (46, 'Ross', 'Abdon', 'Boston', 'Psychology', null, 21, 'Male', 'Middle Eastern', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (47, 'Bill', 'Hadfield', 'Vancouver', 'Economics', null, 20, 'Male', 'Black or African American', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (48, 'Christa', 'Masterton', 'Silicon Valley', 'Biology', null, 18, 'Female', 'Middle Eastern', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (49, 'Dominique', 'Quantrill', 'Vancouver', 'Marketing', 'Biology', 28, 'Female', 'Hispanic or Latinx', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (50, 'Lois', 'Crockatt', 'Vancouver', 'Business Administration', 'Data Science', 24, 'Female', 'Asian', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (51, 'Nalani', 'Gaffey', 'Silicon Valley', 'Cybersecurity', 'Design', 24, 'Polygender', 'Hispanic or Latinx', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (52, 'Ivett', 'Shimuk', 'Boston', 'Economics', 'Communication Studies', 26, 'Female', 'Black or African American', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (53, 'Dal', 'Barmadier', 'Boston', 'Electrical Engineering', null, 24, 'Male', 'Asian', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (54, 'Breanne', 'Crenage', 'Portland', 'Computer Science', 'Communication Studies', 28, 'Female', 'Mixed', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (55, 'Lemmie', 'Adenet', 'Silicon Valley', 'Business Administration', 'Data Science', 20, 'Male', 'Black or African American', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (56, 'Tobiah', 'Ridde', 'Vancouver', 'Marketing', 'Sociology', 23, 'Male', 'Black or African American', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (57, 'Armstrong', 'Goodge', 'Oakland', 'Design', 'Spanish', 26, 'Male', 'Hispanic or Latinx', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (58, 'Janean', 'Graber', 'Portland', 'Bioengineering', null, 18, 'Bigender', 'Asian', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (59, 'Flory', 'Melchior', 'Charlotte', 'Software Engineering', 'Cybersecurity', 20, 'Female', 'Asian', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (60, 'Vanni', 'Robshaw', 'London', 'Bioengineering', null, 20, 'Female', 'Hispanic or Latinx', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (61, 'Georgy', 'Thorald', 'London', 'Entrepreneurship', 'Health Science', 23, 'Male', 'White', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (62, 'Francisca', 'Casetta', 'Boston', 'Marketing', 'Computer Science', 20, 'Female', 'Hispanic or Latinx', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (63, 'Antonella', 'Osmond', 'Vancouver', 'Software Engineering', 'Design', 24, 'Female', 'Mixed', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (64, 'Pammie', 'Currao', 'Oakland', 'Computer Engineering', null, 18, 'Agender', 'Asian', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (65, 'Marla', 'Dommersen', 'Vancouver', 'Computer Science', null, 26, 'Agender', 'White', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (66, 'Onfre', 'Roscow', 'Oakland', 'Design', 'Health Science', 27, 'Male', 'Other', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (67, 'Iseabal', 'Antham', 'Silicon Valley', 'Communications', 'Communication Studies', 22, 'Female', 'Middle Eastern', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (68, 'Montgomery', 'Pask', 'Portland', 'Health Science', 'Philosophy', 20, 'Non-binary', 'Hispanic or Latinx', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (69, 'Hillard', 'Volk', 'Vancouver', 'Management', 'Health Science', 22, 'Male', 'Middle Eastern', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (70, 'Padget', 'Delooze', 'Boston', 'Design', 'Philosophy', 20, 'Male', 'Black or African American', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (71, 'Amandi', 'Vasichev', 'Vancouver', 'Entrepreneurship', 'Health Science', 23, 'Genderqueer', 'Asian', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (72, 'Devlen', 'Bulch', 'Charlotte', 'Cybersecurity', 'Communication Studies', 20, 'Male', 'Asian', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (73, 'Hubie', 'Bruineman', 'Oakland', 'Software Engineering', null, 23, 'Male', 'Asian', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (74, 'Nikki', 'Burlingame', 'Oakland', 'Mathematics', 'Spanish', 21, 'Polygender', 'Asian', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (75, 'Gay', 'Caldwall', 'Silicon Valley', 'Mechanical Engineering', 'Spanish', 20, 'Male', 'Mixed', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (76, 'Hayes', 'Giron', 'Seattle', 'Marketing', 'Communication Studies', 28, 'Male', 'Hispanic or Latinx', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (77, 'Elmore', 'Gittins', 'Boston', 'Software Engineering', 'Spanish', 20, 'Non-binary', 'Middle Eastern', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (78, 'Ruprecht', 'Ziemens', 'Boston', 'Computer Engineering', 'Philosophy', 17, 'Male', 'Middle Eastern', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (79, 'Richard', 'Puckinghorne', 'Oakland', 'Computer Science', 'Data Science', 22, 'Genderqueer', 'Middle Eastern', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (80, 'Wait', 'Sneddon', 'Vancouver', 'Management', 'Computer Science', 20, 'Male', 'Asian', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (81, 'Winifield', 'Levicount', 'Portland', 'Political Science', 'Computer Science', 21, 'Male', 'Black or African American', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (82, 'Eugine', 'Wagge', 'Silicon Valley', 'Psychology', 'Cybersecurity', 28, 'Female', 'White', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (83, 'Virge', 'Deedes', 'Charlotte', 'Political Science', 'Economics', 18, 'Male', 'Mixed', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (84, 'Britte', 'McMillam', 'Charlotte', 'Criminal Justice', null, 27, 'Female', 'Middle Eastern', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (85, 'Nevins', 'Ashtonhurst', 'London', 'Communications', null, 28, 'Male', 'Mixed', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (86, 'Odessa', 'Cowitz', 'Vancouver', 'Communications', null, 26, 'Female', 'Other', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (87, 'Amalea', 'Tegler', 'Oakland', 'Communications', 'Economics', 22, 'Female', 'Hispanic or Latinx', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (88, 'Nicholle', 'Daybell', 'Seattle', 'Electrical Engineering', 'Business Administration', 17, 'Female', 'Black or African American', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (89, 'Yves', 'Shenfish', 'Oakland', 'Marketing', 'Psychology', 26, 'Male', 'Asian', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (90, 'Alyss', 'Ashard', 'Seattle', 'Marketing', 'Cybersecurity', 25, 'Female', 'Other', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (91, 'Lewiss', 'Bockmann', 'Silicon Valley', 'Bioengineering', null, 23, 'Male', 'White', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (92, 'Jonathon', 'Antcliff', 'Boston', 'Marketing', 'Computer Science', 28, 'Male', 'Other', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (93, 'Karlens', 'Roloff', 'Silicon Valley', 'Cybersecurity', 'Business Administration', 22, 'Male', 'Mixed', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (94, 'Pepita', 'Ciccotto', 'London', 'Management', null, 25, 'Female', 'Black or African American', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (95, 'Parnell', 'Fitkin', 'Seattle', 'Computer Science', 'Biology', 25, 'Male', 'Other', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (96, 'Chandler', 'Madine', 'London', 'Computer Engineering', 'Entrepreneurship', 20, 'Male', 'Mixed', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (97, 'Herve', 'Walasik', 'Vancouver', 'Communications', null, 21, 'Male', 'Black or African American', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (98, 'Hasheem', 'Labro', 'Silicon Valley', 'Computer Engineering', 'Health Science', 20, 'Male', 'Black or African American', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (99, 'Neille', 'Blankenship', 'Portland', 'Computer Science', null, 23, 'Female', 'Other', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (100, 'Lucho', 'Nielson', 'Portland', 'Management', null, 22, 'Male', 'Asian', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (101, 'Audry', 'Patshull', 'Portland', 'Psychology', 'Entrepreneurship', 27, 'Female', 'White', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (102, 'Fons', 'Inmett', 'Portland', 'Design', null, 22, 'Male', 'Middle Eastern', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (103, 'Allie', 'Horrell', 'Silicon Valley', 'Computer Engineering', 'Entrepreneurship', 20, 'Male', 'Asian', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (104, 'Palmer', 'Lehrle', 'Boston', 'Nursing', null, 21, 'Male', 'Other', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (105, 'Minda', 'Fullalove', 'Seattle', 'Software Engineering', 'Mathematics', 19, 'Female', 'Black or African American', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (106, 'Daphna', 'Francecione', 'Vancouver', 'Mathematics', 'Health Science', 25, 'Female', 'Other', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (107, 'Frederica', 'Coldman', 'Vancouver', 'Mechanical Engineering', null, 22, 'Female', 'Asian', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (108, 'Kial', 'Weatherburn', 'Boston', 'Management', 'Sociology', 26, 'Female', 'White', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (109, 'Whittaker', 'Redmond', 'Seattle', 'Nursing', 'Health Science', 28, 'Male', 'Middle Eastern', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (110, 'Lorri', 'Garvan', 'Boston', 'Biology', null, 17, 'Female', 'Mixed', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (111, 'Ruperta', 'Kneaphsey', 'Portland', 'Computer Engineering', null, 28, 'Female', 'Asian', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (112, 'Magda', 'Zanre', 'London', 'Political Science', null, 27, 'Polygender', 'Other', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (113, 'Augie', 'Phythean', 'Portland', 'Bioengineering', 'Data Science', 27, 'Male', 'White', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (114, 'Nickey', 'Beauvais', 'London', 'Criminal Justice', null, 23, 'Male', 'White', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (115, 'Suellen', 'Rouch', 'Silicon Valley', 'Mechanical Engineering', null, 23, 'Female', 'Black or African American', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (116, 'Filmore', 'Holburn', 'Seattle', 'Business Administration', null, 22, 'Male', 'Asian', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (117, 'Stearn', 'Cicco', 'Portland', 'Software Engineering', 'Entrepreneurship', 28, 'Non-binary', 'Other', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (118, 'Shaun', 'Kesper', 'Vancouver', 'Business Administration', null, 27, 'Male', 'Asian', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (119, 'Brocky', 'Hargreves', 'Boston', 'Biology', 'Mathematics', 27, 'Male', 'Hispanic or Latinx', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (120, 'Llewellyn', 'Elsip', 'Portland', 'Computer Engineering', 'Sociology', 18, 'Male', 'Hispanic or Latinx', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (121, 'Valerye', 'Strongitharm', 'Portland', 'Health Science', 'Health Science', 28, 'Female', 'Asian', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (122, 'Kailey', 'Allwood', 'Oakland', 'Computer Science', null, 20, 'Female', 'Mixed', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (123, 'Ofelia', 'Hosier', 'London', 'Political Science', 'Entrepreneurship', 23, 'Female', 'White', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (124, 'Phedra', 'Hubber', 'London', 'Design', 'Biology', 23, 'Female', 'Mixed', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (125, 'Bartolomeo', 'Bridywater', 'Charlotte', 'Computer Engineering', null, 20, 'Polygender', 'Hispanic or Latinx', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (126, 'Pasquale', 'Brevitt', 'Seattle', 'Software Engineering', 'Communication Studies', 25, 'Male', 'White', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (127, 'Gretna', 'Zelner', 'Boston', 'Mathematics', null, 25, 'Female', 'Black or African American', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (128, 'Court', 'Goodship', 'Vancouver', 'Nursing', null, 27, 'Male', 'Black or African American', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (129, 'Edgar', 'Siebert', 'Oakland', 'Entrepreneurship', 'Design', 26, 'Male', 'Middle Eastern', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (130, 'Nicol', 'Fonzone', 'Oakland', 'Electrical Engineering', 'Philosophy', 27, 'Male', 'Mixed', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (131, 'Farrel', 'Milburn', 'Charlotte', 'Computer Engineering', 'Health Science', 22, 'Male', 'Other', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (132, 'Jeff', 'Whymark', 'Vancouver', 'Cybersecurity', 'Cybersecurity', 18, 'Male', 'Middle Eastern', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (133, 'Derby', 'Shakesbye', 'Vancouver', 'Criminal Justice', null, 24, 'Genderqueer', 'Other', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (134, 'Liana', 'Hayden', 'Portland', 'Political Science', null, 19, 'Non-binary', 'White', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (135, 'Jozef', 'Humphrys', 'Portland', 'Economics', 'Business Administration', 19, 'Male', 'Black or African American', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (136, 'Sibylle', 'Havile', 'Silicon Valley', 'Entrepreneurship', null, 20, 'Female', 'Hispanic or Latinx', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (137, 'Dyane', 'Duckfield', 'Oakland', 'Biology', null, 25, 'Female', 'Black or African American', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (138, 'Quent', 'Churchward', 'Vancouver', 'Design', 'Psychology', 25, 'Male', 'Mixed', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (139, 'Dilan', 'Brinsford', 'Vancouver', 'Finance', 'Mathematics', 17, 'Male', 'Asian', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (140, 'Goddard', 'Boston', 'Vancouver', 'Political Science', 'Communication Studies', 20, 'Male', 'Mixed', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (141, 'Launce', 'Oris', 'Vancouver', 'Electrical Engineering', 'Data Science', 19, 'Male', 'Other', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (142, 'Jard', 'Magne', 'Portland', 'Design', 'Economics', 19, 'Male', 'Black or African American', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (143, 'Hamil', 'Darrington', 'Charlotte', 'Biochemistry', null, 23, 'Bigender', 'Hispanic or Latinx', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (144, 'Rogers', 'Champkin', 'Portland', 'Marketing', 'Data Science', 24, 'Male', 'White', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (145, 'Emmalynne', 'Mackin', 'Vancouver', 'Business Administration', 'Psychology', 23, 'Genderfluid', 'White', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (146, 'Fran', 'Crunden', 'Portland', 'Biochemistry', null, 19, 'Female', 'Other', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (147, 'Emalee', 'Puttick', 'London', 'Biochemistry', 'Mathematics', 28, 'Female', 'Middle Eastern', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (148, 'Reginauld', 'Loy', 'Oakland', 'Mathematics', 'Business Administration', 26, 'Male', 'Black or African American', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (149, 'Sidoney', 'Barthelmes', 'Oakland', 'Health Science', 'Philosophy', 22, 'Female', 'Black or African American', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (150, 'Neall', 'Heeley', 'Charlotte', 'Business Administration', null, 22, 'Male', 'White', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (151, 'Marcellina', 'Goldbourn', 'London', 'Marketing', 'Entrepreneurship', 20, 'Female', 'Other', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (152, 'Annadiana', 'Paraman', 'Boston', 'Computer Science', null, 26, 'Female', 'Hispanic or Latinx', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (153, 'Shanda', 'Hebble', 'Oakland', 'Psychology', 'Sociology', 19, 'Female', 'Middle Eastern', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (154, 'Billie', 'Roche', 'Portland', 'Political Science', 'Communication Studies', 21, 'Female', 'Hispanic or Latinx', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (155, 'Klara', 'Menault', 'Boston', 'Mechanical Engineering', 'Health Science', 18, 'Female', 'Asian', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (156, 'Cassondra', 'Fraine', 'Portland', 'Biochemistry', null, 25, 'Female', 'Asian', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (157, 'Oneida', 'Agglione', 'Vancouver', 'Management', 'Cybersecurity', 27, 'Polygender', 'Middle Eastern', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (158, 'Maison', 'Witham', 'Portland', 'Health Science', 'Biology', 21, 'Agender', 'Asian', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (159, 'Sylvan', 'Geeritz', 'London', 'Psychology', null, 28, 'Male', 'White', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (160, 'Cos', 'Gulvin', 'Silicon Valley', 'Software Engineering', null, 18, 'Bigender', 'Other', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (161, 'Veradis', 'Cutsforth', 'Seattle', 'Criminal Justice', 'Data Science', 28, 'Female', 'Middle Eastern', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (162, 'Zaccaria', 'Edgington', 'Silicon Valley', 'Entrepreneurship', 'Computer Science', 17, 'Male', 'Other', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (163, 'Orelie', 'Costan', 'Portland', 'Bioengineering', null, 19, 'Female', 'Other', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (164, 'Conan', 'Aery', 'Charlotte', 'Electrical Engineering', 'Design', 28, 'Male', 'Hispanic or Latinx', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (165, 'Dane', 'Guice', 'Portland', 'Computer Engineering', null, 26, 'Male', 'Middle Eastern', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (166, 'Niel', 'Grinter', 'Charlotte', 'Entrepreneurship', null, 24, 'Male', 'Mixed', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (167, 'Sephira', 'Lambeth', 'Portland', 'Business Administration', 'Psychology', 28, 'Female', 'Hispanic or Latinx', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (168, 'Raul', 'Callear', 'London', 'Electrical Engineering', 'Design', 17, 'Male', 'Hispanic or Latinx', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (169, 'Vikky', 'Paternoster', 'Portland', 'Software Engineering', null, 20, 'Female', 'Other', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (170, 'Midge', 'Van de Vlies', 'Vancouver', 'Mathematics', 'Design', 25, 'Female', 'Middle Eastern', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (171, 'Horatio', 'Willock', 'Vancouver', 'Business Administration', null, 22, 'Male', 'Black or African American', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (172, 'Violetta', 'Alexis', 'Charlotte', 'Data Science', null, 23, 'Female', 'Mixed', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (173, 'Wyndham', 'Toothill', 'Boston', 'Entrepreneurship', 'Entrepreneurship', 17, 'Male', 'Mixed', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (174, 'Mattias', 'Byham', 'Charlotte', 'Mechanical Engineering', null, 24, 'Male', 'White', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (175, 'Rourke', 'Hurne', 'Portland', 'Health Science', 'Communication Studies', 23, 'Male', 'Black or African American', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (176, 'Harald', 'Dumingo', 'Vancouver', 'Chemical Engineering', null, 18, 'Male', 'White', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (177, 'Cicily', 'Ruffli', 'Seattle', 'Design', null, 22, 'Female', 'Asian', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (178, 'Mitchel', 'Mougeot', 'Boston', 'Mechanical Engineering', null, 20, 'Male', 'Mixed', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (179, 'Mitchel', 'Letterese', 'Silicon Valley', 'Biochemistry', null, 27, 'Male', 'Middle Eastern', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (180, 'Riley', 'Chiddy', 'London', 'Entrepreneurship', 'Computer Science', 27, 'Non-binary', 'Asian', 2028);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (181, 'Trudie', 'Squibbes', 'Vancouver', 'Data Science', null, 26, 'Female', 'Black or African American', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (182, 'Kristopher', 'Gearing', 'Boston', 'Economics', null, 20, 'Male', 'Mixed', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (183, 'Ida', 'Percival', 'Oakland', 'Management', null, 21, 'Genderfluid', 'Mixed', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (184, 'Bebe', 'Ridgley', 'Vancouver', 'Entrepreneurship', 'Data Science', 27, 'Female', 'Black or African American', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (185, 'Nonie', 'Galbraith', 'London', 'Entrepreneurship', 'Biology', 20, 'Female', 'Mixed', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (186, 'Tasha', 'Paolo', 'London', 'Psychology', null, 17, 'Female', 'Black or African American', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (187, 'Gaye', 'Kupis', 'Oakland', 'Communications', 'Spanish', 17, 'Female', 'Middle Eastern', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (188, 'Darice', 'Nials', 'Boston', 'Political Science', 'Computer Science', 24, 'Female', 'Black or African American', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (189, 'Ephrem', 'Boys', 'Charlotte', 'Design', 'Entrepreneurship', 24, 'Male', 'Black or African American', 2026);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (190, 'Garrot', 'Bosworth', 'Boston', 'Software Engineering', 'Entrepreneurship', 19, 'Male', 'Hispanic or Latinx', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (191, 'Kelly', 'Lampitt', 'Seattle', 'Biochemistry', 'Psychology', 20, 'Male', 'Middle Eastern', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (192, 'Vivi', 'Vynehall', 'Seattle', 'Cybersecurity', null, 26, 'Female', 'Asian', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (193, 'Riki', 'Camlin', 'Charlotte', 'Entrepreneurship', 'Economics', 19, 'Female', 'Middle Eastern', 2027);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (194, 'Nikolaus', 'Katte', 'Vancouver', 'Mechanical Engineering', 'Biology', 22, 'Male', 'Other', 2024);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (195, 'Sarita', 'Eixenberger', 'Silicon Valley', 'Mathematics', 'Communication Studies', 18, 'Female', 'Other', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (196, 'Corrie', 'Airlie', 'Silicon Valley', 'Marketing', 'Psychology', 28, 'Male', 'Mixed', 2025);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (197, 'Ardyth', 'Durham', 'Seattle', 'Electrical Engineering', 'Computer Science', 18, 'Female', 'White', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (198, 'Mikol', 'Patron', 'Charlotte', 'Biochemistry', null, 26, 'Male', 'Middle Eastern', 2030);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (199, 'Alessandra', 'Stowers', 'Vancouver', 'Management', 'Entrepreneurship', 26, 'Female', 'Asian', 2029);
insert into student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) values (200, 'Ethe', 'Brearty', 'Seattle', 'Nursing', 'Psychology', 26, 'Male', 'Black or African American', 2027);

-- 4. club
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (1, 'Investment Club', 'Undergraduate', 'Boston', 'Sed ante.', 77, 17);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (2, 'Collective Coding Bootcamp Club', 'Undergraduate', 'Boston', 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', 14, 163);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (3, 'Computer Science Club', 'Graduate', 'Oakland', 'Nam tristique tortor eu pede.', 238, 133);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (4, 'Marketing Association', 'Graduate', 'Oakland', 'Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 8, 203);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (5, 'Entrepreneurship Society', 'Graduate', 'Oakland', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', 274, 131);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (6, 'Entrepreneurship Society', 'Undergraduate', 'Oakland', 'Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.', 104, 6);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (7, 'Investment Club', 'Undergraduate', 'Oakland', 'In congue. Etiam justo. Etiam pretium iaculis justo.', 162, 35);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (8, 'Collective Coding Bootcamp Club', 'Graduate', 'Oakland', 'Nam nulla.', 294, 185);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (9, 'Data Science', 'Graduate', 'London', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 22, 216);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (10, 'Husky Hockey Club', 'Graduate', 'Boston', 'Maecenas tincidunt lacus at velit.', 16, 156);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (11, 'Entrepreneurship Society', 'Graduate', 'Oakland', 'Nullam porttitor lacus at turpis.', 32, 199);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (12, 'Investment Club', 'Undergraduate', 'Oakland', 'Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue.', 19, 169);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (13, 'Business Analytics Association', 'Graduate', 'Oakland', 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', 165, 272);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (14, 'Data Science', 'Undergraduate', 'Boston', 'Integer a nibh. In quis justo.', 89, 158);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (15, 'Business Analytics Association', 'Graduate', 'London', 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 12, 48);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (16, 'Investment Club', 'Undergraduate', 'Boston', 'In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', 92, 139);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (17, 'Collective Coding Bootcamp Club', 'Graduate', 'Oakland', 'Nam nulla.', 265, 133);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (18, 'Husky Hockey Club', 'Undergraduate', 'Boston', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', 15, 197);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (19, 'Consulting Club', 'Graduate', 'Boston', 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.', 14, 253);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (20, 'Investment Club', 'Undergraduate', 'London', 'Etiam faucibus cursus urna.', 272, 171);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (21, 'Consulting Club', 'Graduate', 'Boston', 'Sed ante.', 160, 215);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (22, 'Husky Hockey Club', 'Graduate', 'London', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', 65, 273);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (23, 'Marketing Association', 'Graduate', 'Boston', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 248, 113);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (24, 'Business Analytics Association', 'Graduate', 'Boston', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 299, 278);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (25, 'Husky Hockey Club', 'Graduate', 'Boston', 'In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', 37, 91);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (26, 'Husky Hockey Club', 'Undergraduate', 'London', 'Nulla suscipit ligula in lacus.', 126, 4);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (27, 'Consulting Club', 'Graduate', 'Oakland', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 55, 129);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (28, 'Husky Hockey Club', 'Undergraduate', 'Oakland', 'Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.', 61, 23);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (29, 'Business Analytics Association', 'Undergraduate', 'Oakland', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 271, 249);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (30, 'Husky Hockey Club', 'Undergraduate', 'Oakland', 'In hac habitasse platea dictumst.', 122, 167);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (31, 'Marketing Association', 'Undergraduate', 'London', 'Etiam faucibus cursus urna. Ut tellus.', 188, 238);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (32, 'Entrepreneurship Society', 'Graduate', 'Boston', 'In est risus, auctor sed, tristique in, tempus sit amet, sem.', 202, 64);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (33, 'Data Science', 'Graduate', 'Oakland', 'Donec semper sapien a libero. Nam dui.', 24, 275);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (34, 'Investment Club', 'Undergraduate', 'Boston', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', 104, 102);
insert into club (clubID, name, gradLevel, campus, description, numMembers, numSearches) values (35, 'Business Analytics Association', 'Graduate', 'London', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', 29, 12);

-- 5. event
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (1, 'Curry Student Center Room 420', '2025-01-15', 'Learn about machine learning fundamentals and practical applications.', 'ML Workshop', '2025-01-15 18:00:00', '2025-01-15 20:30:00', 78, 56, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (2, 'Richards Hall 235', '2025-01-22', 'Practice your coding skills with fun challenges and prizes.', 'Coding Challenge', '2025-01-22 19:00:00', '2025-01-22 21:00:00', 77, 46, 0, 0, 'Active Members Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (3, 'Snell Library Room 112', '2025-02-05', 'Connect with professionals and expand your network.', 'Networking Event', '2025-02-05 17:30:00', '2025-02-05 19:30:00', 133, 33, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (4, 'Ryder Hall 155', '2025-02-12', 'Interactive workshop on industry best practices.', 'Workshop Series', '2025-02-12 18:00:00', '2025-02-12 20:00:00', 48, 44, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (5, 'Churchill Hall 103', '2025-02-18', 'Watch entrepreneurs pitch their innovative ideas.', 'Startup Pitch Night', '2025-02-18 19:00:00', '2025-02-18 21:30:00', 111, 22, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (6, 'Egan Research Center', '2025-02-25', 'Develop your technical and leadership skills.', 'Training Workshop', '2025-02-25 16:00:00', '2025-02-25 18:00:00', 128, 52, 0, 0, 'General Members Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (7, 'Marino Recreation Center', '2025-03-03', 'Get your resume reviewed by industry professionals.', 'Resume Review Session', '2025-03-03 17:00:00', '2025-03-03 19:00:00', 145, 18, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (8, 'Behrakis Health Sciences Center', '2025-03-10', 'Prepare for upcoming competitions.', 'Competition Prep', '2025-03-10 18:30:00', '2025-03-10 20:30:00', 137, 40, 0, 0, 'Active Members Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (9, 'West Village H Common Room', '2025-03-17', 'Learn how to ace your career fair interviews.', 'Career Fair Prep', '2025-03-17 19:00:00', '2025-03-17 21:00:00', 53, 19, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (10, 'International Village Game Room', '2025-03-24', 'Connect with peers and build lasting relationships.', 'Leadership Workshop', '2025-03-24 18:00:00', '2025-03-24 20:00:00', 17, 3, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (11, 'Forsyth Building 236', '2025-03-28', 'Fun team building exercises and activities.', 'Team Building Activity', '2025-03-28 17:30:00', '2025-03-28 19:30:00', 19, 12, 0, 0, 'General Members Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (12, 'Hayden Hall Lobby', '2025-04-02', 'Hear from distinguished alumni about their career paths.', 'Alumni Q&A', '2025-04-02 19:00:00', '2025-04-02 21:00:00', 128, 54, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (13, 'Shillman Hall 215', '2025-04-08', 'Meet fellow club members in a casual setting.', 'Social Mixer', '2025-04-08 18:00:00', '2025-04-08 20:00:00', 136, 16, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (14, 'Hurtig Hall 205', '2025-04-15', 'Welcome new members to the club!', 'Welcome Event', '2025-04-15 18:30:00', '2025-04-15 20:30:00', 121, 20, 0, 0, 'Open');
<<<<<<< HEAD
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (15, 'Dodge Hall 150', '2024-12-10', 'Celebrate the end of the semester with your club.', 'End of Year Celebration', '2024-12-10 19:00:00', '2024-12-10 22:00:00', 124, 35, 0, 1, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (16, 'Curry Student Center Room 420', '2025-01-28', 'Enjoy food from around the world.', 'Food Festival', '2025-01-28 18:00:00', '2025-01-28 20:30:00', 31, 45, 1, 0, 'Open');
=======
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (15, 'Dodge Hall 150', '2024-12-10', 'Celebrate the end of the semester with your club.', 'End of Year Celebration', '2024-12-10 19:00:00', '2024-12-10 22:00:00', 124, 35, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (16, 'Curry Student Center Room 420', '2025-01-28', 'Enjoy food from around the world.', 'Food Festival', '2025-01-28 18:00:00', '2025-01-28 20:30:00', 31, 4, 0, 0, 'Open');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (17, 'Richards Hall 235', '2025-02-20', 'Hear from industry leaders about career opportunities.', 'Industry Panel', '2025-02-20 19:00:00', '2025-02-20 21:00:00', 59, 22, 0, 0, 'General Members Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (18, 'Snell Library Room 112', '2025-03-05', 'Prepare for the job market with expert guidance.', 'Career Fair Prep', '2025-03-05 17:00:00', '2025-03-05 19:00:00', 150, 27, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (19, 'Ryder Hall 155', '2025-03-12', 'Distinguished speaker series featuring industry experts.', 'Guest Speaker Series', '2025-03-12 18:30:00', '2025-03-12 20:30:00', 73, 40, 0, 0, 'General Members Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (20, 'Churchill Hall 103', '2025-03-19', 'Give back to the community through service.', 'Volunteer Event', '2025-03-19 14:00:00', '2025-03-19 17:00:00', 100, 54, 0, 0, 'Open');
<<<<<<< HEAD
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (21, 'Egan Research Center', '2025-03-26', 'Panel discussion with industry professionals.', 'Industry Panel', '2025-03-26 19:00:00', '2025-03-26 21:00:00', 51, 53, 1, 0, 'Active Members Only');
=======
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (21, 'Egan Research Center', '2025-03-26', 'Panel discussion with industry professionals.', 'Industry Panel', '2025-03-26 19:00:00', '2025-03-26 21:00:00', 51, 50, 0, 0, 'Active Members Only');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (22, 'Marino Recreation Center', '2025-04-05', 'Enjoy international cuisine and connect with members.', 'Food Festival', '2025-04-05 18:00:00', '2025-04-05 20:30:00', 97, 55, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (23, 'Behrakis Health Sciences Center', '2025-04-10', 'Hands-on training in key skills.', 'Training Workshop', '2025-04-10 17:30:00', '2025-04-10 19:30:00', 13, 12, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (24, 'West Village H Common Room', '2025-04-16', 'Get ready for the hackathon season.', 'Hackathon Prep', '2025-04-16 18:00:00', '2025-04-16 20:30:00', 43, 40, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (25, 'International Village Game Room', '2025-04-22', 'Learn from industry experts in an interactive panel.', 'Industry Panel', '2025-04-22 19:00:00', '2025-04-22 21:00:00', 124, 12, 0, 0, 'General Members Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (26, 'Forsyth Building 236', '2024-11-20', 'Introduction to Python programming fundamentals.', 'Python Basics', '2024-11-20 18:00:00', '2024-11-20 20:00:00', 51, 41, 0, 1, 'Open');
<<<<<<< HEAD
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (27, 'Hayden Hall Lobby', '2025-01-30', 'Get your resume professionally reviewed.', 'Resume Review Session', '2025-01-30 17:00:00', '2025-01-30 19:00:00', 36, 52, 1, 0, 'Officers Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (28, 'Shillman Hall 215', '2025-02-14', 'Advanced machine learning techniques workshop.', 'ML Workshop', '2025-02-14 18:30:00', '2025-02-14 21:00:00', 55, 33, 0, 0, 'Active Members Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (29, 'Hurtig Hall 205', '2025-02-28', 'Learn about AI and its applications.', 'Info Session', '2025-02-28 18:00:00', '2025-02-28 20:00:00', 7, 22, 1, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (30, 'Dodge Hall 150', '2025-03-07', 'Connect with alumni and hear their career stories.', 'Alumni Q&A', '2025-03-07 19:00:00', '2025-03-07 21:00:00', 130, 22, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (31, 'Curry Student Center Room 420', '2025-03-14', 'Develop leadership skills for your career.', 'Leadership Workshop', '2025-03-14 18:00:00', '2025-03-14 20:30:00', 104, 27, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (32, 'Richards Hall 235', '2025-03-21', 'Welcome new members and introduce the club.', 'Welcome Event', '2025-03-21 17:30:00', '2025-03-21 19:30:00', 52, 8, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (33, 'Snell Library Room 112', '2025-03-28', 'Network with professionals in your field.', 'Networking Mixer', '2025-03-28 18:30:00', '2025-03-28 20:30:00', 38, 48, 1, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (34, 'Ryder Hall 155', '2025-04-04', 'Panel featuring successful industry professionals.', 'Industry Panel', '2025-04-04 19:00:00', '2025-04-04 21:00:00', 41, 49, 1, 0, 'General Members Only');
=======
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (27, 'Hayden Hall Lobby', '2025-01-30', 'Get your resume professionally reviewed.', 'Resume Review Session', '2025-01-30 17:00:00', '2025-01-30 19:00:00', 36, 5, 0, 0, 'Officers Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (28, 'Shillman Hall 215', '2025-02-14', 'Advanced machine learning techniques workshop.', 'ML Workshop', '2025-02-14 18:30:00', '2025-02-14 21:00:00', 55, 33, 0, 0, 'Active Members Only');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (29, 'Hurtig Hall 205', '2025-02-28', 'Learn about AI and its applications.', 'Info Session', '2025-02-28 18:00:00', '2025-02-28 20:00:00', 7, 2, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (30, 'Dodge Hall 150', '2025-03-07', 'Connect with alumni and hear their career stories.', 'Alumni Q&A', '2025-03-07 19:00:00', '2025-03-07 21:00:00', 130, 22, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (31, 'Curry Student Center Room 420', '2025-03-14', 'Develop leadership skills for your career.', 'Leadership Workshop', '2025-03-14 18:00:00', '2025-03-14 20:30:00', 104, 27, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (32, 'Richards Hall 235', '2025-03-21', 'Welcome new members and introduce the club.', 'Welcome Event', '2025-03-21 17:30:00', '2025-03-21 19:30:00', 52, 8, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (33, 'Snell Library Room 112', '2025-03-28', 'Network with professionals in your field.', 'Networking Mixer', '2025-03-28 18:30:00', '2025-03-28 20:30:00', 38, 8, 0, 0, 'Open');
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (34, 'Ryder Hall 155', '2025-04-04', 'Panel featuring successful industry professionals.', 'Industry Panel', '2025-04-04 19:00:00', '2025-04-04 21:00:00', 41, 9, 0, 0, 'General Members Only');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into event (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) values (35, 'Churchill Hall 103', '2024-12-05', 'Introduce new members to the club community.', 'Welcome Event', '2024-12-05 18:00:00', '2024-12-05 20:00:00', 132, 32, 0, 1, 'Open');

-- 6. administrator
insert into administrator (systemID, firstName, lastName, email, adminID) values (1, 'Dulcie', 'Stratton', 'dstratton0@omniture.com', 1);
insert into administrator (systemID, firstName, lastName, email, adminID) values (2, 'Aeriell', 'Domenichelli', 'adomenichelli1@bluehost.com', 2);
insert into administrator (systemID, firstName, lastName, email, adminID) values (3, 'Gamaliel', 'Jojic', 'gjojic2@independent.co.uk', 3);
insert into administrator (systemID, firstName, lastName, email, adminID) values (4, 'Alis', 'Balassa', 'abalassa3@homestead.com', 4);
insert into administrator (systemID, firstName, lastName, email, adminID) values (5, 'Thalia', 'Gabbetis', 'tgabbetis4@cpanel.net', 5);
insert into administrator (systemID, firstName, lastName, email, adminID) values (6, 'Greta', 'McGlynn', 'gmcglynn5@hc360.com', 6);
insert into administrator (systemID, firstName, lastName, email, adminID) values (7, 'Tamiko', 'Radcliffe', 'tradcliffe6@uol.com.br', 7);
insert into administrator (systemID, firstName, lastName, email, adminID) values (8, 'Allie', 'Brashier', 'abrashier7@wikimedia.org', 8);
insert into administrator (systemID, firstName, lastName, email, adminID) values (9, 'Harp', 'Bliben', 'hbliben8@meetup.com', 9);
insert into administrator (systemID, firstName, lastName, email, adminID) values (10, 'Brocky', 'Leversha', 'bleversha9@e-recht24.de', 10);
insert into administrator (systemID, firstName, lastName, email, adminID) values (1, 'Julienne', 'Featherstonhaugh', 'jfeatherstonhaugha@fotki.com', 11);
insert into administrator (systemID, firstName, lastName, email, adminID) values (2, 'Fran', 'Getch', 'fgetchb@histats.com', 12);
insert into administrator (systemID, firstName, lastName, email, adminID) values (3, 'Jaquenetta', 'Crooke', 'jcrookec@skype.com', 13);
insert into administrator (systemID, firstName, lastName, email, adminID) values (4, 'Nils', 'Lenham', 'nlenhamd@tripadvisor.com', 14);
insert into administrator (systemID, firstName, lastName, email, adminID) values (5, 'Kelsey', 'Jovey', 'kjoveye@photobucket.com', 15);
insert into administrator (systemID, firstName, lastName, email, adminID) values (6, 'Rafe', 'Lenoir', 'rlenoirf@t.co', 16);
insert into administrator (systemID, firstName, lastName, email, adminID) values (7, 'Earvin', 'Bartolomieu', 'ebartolomieug@blogtalkradio.com', 17);
insert into administrator (systemID, firstName, lastName, email, adminID) values (8, 'Caesar', 'Kermath', 'ckermathh@vimeo.com', 18);
insert into administrator (systemID, firstName, lastName, email, adminID) values (9, 'Albina', 'Lynnitt', 'alynnitti@webeden.co.uk', 19);
insert into administrator (systemID, firstName, lastName, email, adminID) values (10, 'Rabbi', 'Saundercock', 'rsaundercockj@twitter.com', 20);
insert into administrator (systemID, firstName, lastName, email, adminID) values (1, 'Conan', 'Rylett', 'crylettk@nps.gov', 21);
insert into administrator (systemID, firstName, lastName, email, adminID) values (2, 'Kiri', 'Ketteman', 'kkettemanl@ed.gov', 22);
insert into administrator (systemID, firstName, lastName, email, adminID) values (3, 'Cullin', 'Dengate', 'cdengatem@whitehouse.gov', 23);
insert into administrator (systemID, firstName, lastName, email, adminID) values (4, 'Rodie', 'Plowright', 'rplowrightn@studiopress.com', 24);
insert into administrator (systemID, firstName, lastName, email, adminID) values (5, 'Loreen', 'Impey', 'limpeyo@springer.com', 25);
insert into administrator (systemID, firstName, lastName, email, adminID) values (6, 'Suellen', 'Vinnick', 'svinnickp@furl.net', 26);
insert into administrator (systemID, firstName, lastName, email, adminID) values (7, 'Tildi', 'Brimson', 'tbrimsonq@sogou.com', 27);
insert into administrator (systemID, firstName, lastName, email, adminID) values (8, 'Iain', 'Karpychev', 'ikarpychevr@yolasite.com', 28);
insert into administrator (systemID, firstName, lastName, email, adminID) values (9, 'Derk', 'O''Hone', 'dohones@squarespace.com', 29);
insert into administrator (systemID, firstName, lastName, email, adminID) values (10, 'Sella', 'Goodliff', 'sgoodlifft@hatena.ne.jp', 30);
insert into administrator (systemID, firstName, lastName, email, adminID) values (1, 'Jenna', 'Tapsfield', 'jtapsfieldu@surveymonkey.com', 31);
insert into administrator (systemID, firstName, lastName, email, adminID) values (2, 'Lizette', 'Van Hesteren', 'lvanhesterenv@walmart.com', 32);
insert into administrator (systemID, firstName, lastName, email, adminID) values (3, 'Katrine', 'Ell', 'kellw@parallels.com', 33);
insert into administrator (systemID, firstName, lastName, email, adminID) values (4, 'Alic', 'Stanyland', 'astanylandx@seattletimes.com', 34);
insert into administrator (systemID, firstName, lastName, email, adminID) values (5, 'Dewie', 'Morson', 'dmorsony@adobe.com', 35);
insert into administrator (systemID, firstName, lastName, email, adminID) values (6, 'Fonz', 'Tizard', 'ftizardz@theguardian.com', 36);
insert into administrator (systemID, firstName, lastName, email, adminID) values (7, 'Karola', 'Klaassens', 'kklaassens10@mashable.com', 37);
insert into administrator (systemID, firstName, lastName, email, adminID) values (8, 'Kinna', 'Cantle', 'kcantle11@cmu.edu', 38);
insert into administrator (systemID, firstName, lastName, email, adminID) values (9, 'Ravi', 'Cardoso', 'rcardoso12@ucoz.ru', 39);
insert into administrator (systemID, firstName, lastName, email, adminID) values (10, 'Cristi', 'Argent', 'cargent13@pbs.org', 40);

-- 7. eboard
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (1, 1, 'Rog Dobbings', 'Mona Torbard', 'Onofredo Bumphrey', 'Ricard Winterflood');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (2, 2, 'Burlie Gildersleeve', 'Bradford Ratt', 'Marga Fluck', 'Adrian Crewdson');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (3, 3, 'Giuditta Jenno', 'Mitchel Callinan', 'Easter Currom', 'Upton Barnwille');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (4, 4, 'Alejandra Masseo', 'Winona Bru', 'Roderic Eggleston', 'Lauri Ryland');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (5, 5, 'Reider Winchurst', 'Danny Henkens', 'Imelda Heeney', 'Danell Stanbridge');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (6, 6, 'Tarrah Grinyov', 'Pauli Bearn', 'Alvy Elles', 'Culley Duffyn');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (7, 7, 'Orlando Bonnefin', 'Margeaux Juanes', 'Rayner Hessentaler', 'Leigh Kirkby');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (8, 8, 'Hewie Deverell', 'Skippie Vink', 'Jaimie Fulk', 'Randy Ferfulle');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (9, 9, 'Pearl Sealeaf', 'Joella Sheerin', 'Rustin Egell', 'Brandi Tolliday');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (10, 10, 'Gonzales Capron', 'Concordia Durdy', 'Talbot Jolley', 'Kaiser Bellchamber');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (11, 11, 'Tobie Smissen', 'Corette Batkin', 'Renault Harpin', 'Lotte Keeley');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (12, 12, 'Elijah Warr', 'Fabien Angier', 'Gene Harridge', 'Madge Spellman');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (13, 13, 'Tucker Poyle', 'Else Growden', 'Inesita McMullen', 'Vitia Brech');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (14, 14, 'Camala Renac', 'Gilligan Vaune', 'Bary Kolinsky', 'Nev Large');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (15, 15, 'My Keats', 'Bengt Killiam', 'Edee Balsom', 'Skipper Wikey');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (16, 16, 'Dyanne Labbez', 'Susan Bloxsome', 'Ann Asbury', 'Craig Marsland');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (17, 17, 'Brendon Sheere', 'Tallie Crab', 'Mattie Bolingbroke', 'Oswell Gronauer');
<<<<<<< HEAD
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (18, 18, 'Claudette Eccleston', 'Kellia Trett', 'Wandie Tuttle', 'Fleur Brazur');
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (19, 19, 'Franny Rose', 'Bob Zoren', 'Salomi Edon', 'Verine Jarrold');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (20, 20, 'Demetra Eate', 'Elmira Humphrys', 'Eileen Bawme', 'Dav Fend');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (21, 21, 'Rea Handley', 'Anselma Abbey', 'Roland Creaven', 'Freida Gilbank');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (22, 22, 'Avictor Cowcha', 'Trudi O''Docherty', 'Isabella Chelley', 'Malorie Battlestone');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (23, 23, 'Dory Schrir', 'Lana Sander', 'Tanner Annies', 'Avril Kitchener');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (24, 24, 'Franzen Dumini', 'Richie Bartelet', 'Ode Colton', 'Elvyn Azema');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (25, 25, 'Norean Pughe', 'Jayson Heinrich', 'Franny Yurmanovev', 'Kendall Moncey');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (26, 26, 'Lilia Keeney', 'Brocky Godlonton', 'Kassandra De Giorgi', 'Chalmers Pentycost');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (27, 27, 'Adina Piecha', 'Tedra Witheridge', 'Cheri de Clerk', 'Valida Toxell');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (28, 28, 'Adrienne Compston', 'Godiva Szymanowski', 'Kirsteni Bodicam', 'Carolin Bernardotti');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (29, 29, 'Mei Fishlee', 'Humfrey Halladay', 'Adelle Triplow', 'Philip Corneliussen');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (30, 30, 'Kasey Barok', 'Dulsea Sisse', 'Jandy O''Sullivan', 'Rice Haldane');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (31, 31, 'Meier Morrel', 'Clarinda Hembling', 'Queenie Keelan', 'Rosabella Sanney');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (32, 32, 'Thalia Oxbury', 'Rheba Pomphrey', 'Teirtza Munroe', 'Lind Cashin');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (33, 33, 'Yorgo MacCulloch', 'Benny Vella', 'Giustina Trimmill', 'Cherilynn Carlick');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (34, 34, 'Rhianon Bramham', 'Carlotta MacGoun', 'Felix Timoney', 'Haywood Penticost');
insert into eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) values (35, 35, 'Davey Gorring', 'Wilbur Stihl', 'Yance Enticott', 'Anselma Oglevie');

-- 8. studentEmails
<<<<<<< HEAD
insert into studentEmails (studentID, email) values (27, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (157, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (122, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (29, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (174, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (11, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (34, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (12, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (109, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (169, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (137, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (82, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (110, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (69, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (45, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (120, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (11, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (154, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (136, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (82, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (149, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (73, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (76, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (62, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (163, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (42, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (172, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (167, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (37, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (154, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (30, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (174, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (143, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (85, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (143, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (7, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (78, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (25, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (17, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (192, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (183, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (33, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (87, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (50, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (199, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (75, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (105, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (51, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (73, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (17, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (94, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (124, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (196, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (181, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (197, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (168, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (122, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (151, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (11, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (154, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (10, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (181, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (89, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (47, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (84, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (117, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (153, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (194, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (111, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (45, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (77, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (145, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (85, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (128, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (72, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (120, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (96, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (9, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (58, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (172, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (138, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (179, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (33, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (187, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (12, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (82, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (49, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (69, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (31, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (98, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (51, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (102, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (190, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (193, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (15, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (168, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (165, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (98, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (48, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (18, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (54, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (36, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (111, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (70, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (113, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (26, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (158, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (86, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (182, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (98, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (16, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (168, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (106, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (108, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (142, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (166, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (40, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (171, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (186, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (155, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (192, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (67, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (160, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (150, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (119, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (101, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (104, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (183, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (50, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (3, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (75, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (153, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (22, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (38, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (59, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (45, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (195, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (134, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (125, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (175, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (136, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (193, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (178, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (159, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (155, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (5, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (151, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (16, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (151, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (179, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (125, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (95, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (151, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (110, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (97, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (74, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (144, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (44, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (157, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (193, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (127, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (43, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (62, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (166, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (149, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (102, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (9, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (45, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (166, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (2, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (53, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (22, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (15, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (187, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (32, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (193, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (6, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (15, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (127, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (81, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (102, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (21, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (198, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (16, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (127, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (139, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (28, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (35, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (63, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (39, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (128, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (120, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (61, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (78, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (65, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (10, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (18, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (98, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (33, 'error: Field ''firstName'' not found');
insert into studentEmails (studentID, email) values (52, 'error: Field ''firstName'' not found');


-- 9. update
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (10, 'pending', '2025-08-27 17:07:35', '2025-11-11 18:46:28', '2025-01-04 03:08:55', 'Database migration', 'completed', 10);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (12, 'in progress', '2025-07-06 10:58:53', '2025-03-01 11:58:52', '2025-08-14 00:05:42', 'Database migration', 'in progress', 1);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (18, 'approved', '2025-07-25 00:34:10', '2025-05-24 14:39:13', '2025-08-05 23:17:31', 'Security patch', 'testing', 3);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (16, 'approved', '2025-08-15 22:25:38', '2025-09-20 12:58:39', '2025-12-02 18:32:08', 'User interface update', 'completed', 7);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (5, 'pending', '2025-06-17 04:09:00', '2025-11-09 03:44:01', '2025-07-28 05:36:58', 'Documentation update', 'delayed', 2);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (13, 'waiting for approval', '2025-09-07 20:04:21', '2025-10-13 12:52:29', '2025-06-09 17:08:29', 'Feature enhancement', 'scheduled', 5);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (2, 'cancelled', '2025-02-03 19:56:11', '2025-08-13 19:36:57', '2025-03-15 00:51:50', 'User interface update', 'not available', 4);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (13, 'approved', '2025-06-27 20:25:11', '2025-07-14 10:42:13', '2025-03-06 05:16:41', 'User interface update', 'scheduled', 9);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (17, 'waiting for approval', '2025-08-02 13:44:20', '2025-12-18 01:10:59', '2025-04-03 01:07:48', 'Feature enhancement', 'completed', 8);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (9, 'waiting for approval', '2025-12-17 01:23:13', '2025-03-19 01:46:43', '2025-03-27 16:18:32', 'Code refactoring', 'completed', 7);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (4, 'cancelled', '2025-12-14 00:16:43', '2025-07-25 05:35:32', '2025-03-23 21:28:18', 'Server maintenance', 'not available', 5);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (9, 'in progress', '2025-03-16 00:48:43', '2025-10-14 12:52:24', '2025-11-27 04:59:19', 'Database migration', 'under review', 10);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (5, 'completed', '2025-05-13 04:44:29', '2025-04-06 18:04:06', '2025-04-12 03:00:21', 'API integration', 'under review', 9);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (9, 'on hold', '2025-02-24 22:26:56', '2025-10-08 03:08:51', '2025-06-01 03:47:07', 'Code refactoring', 'not available', 1);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (2, 'waiting for approval', '2025-10-27 21:58:11', '2025-12-22 22:00:26', '2025-06-04 11:21:15', 'Server maintenance', 'available', 10);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (12, 'completed', '2025-01-24 23:44:32', '2025-02-18 09:15:22', '2025-02-22 06:52:52', 'Documentation update', 'cancelled', 3);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (16, 'waiting for approval', '2025-04-09 03:10:25', '2025-04-18 11:21:52', '2025-11-24 00:22:36', 'Bug fix', 'available', 4);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (19, 'failed', '2025-08-17 14:34:54', '2025-10-15 15:05:27', '2025-11-08 04:16:17', 'Documentation update', 'pending', 1);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (11, 'pending', '2025-07-03 15:40:44', '2025-06-11 19:55:27', '2025-12-25 10:19:54', 'Database migration', 'available', 1);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (4, 'needs review', '2025-04-22 09:58:28', '2025-01-06 15:00:43', '2025-07-03 18:37:31', 'Code refactoring', 'testing', 2);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (3, 'failed', '2025-10-29 10:37:27', '2025-07-27 08:18:50', '2025-07-19 12:53:27', 'Database migration', 'testing', 6);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (15, 'pending', '2025-05-26 16:52:52', '2025-04-30 09:41:28', '2025-09-14 16:53:53', 'Performance optimization', 'pending', 10);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (9, 'approved', '2025-01-07 04:50:41', '2025-09-08 07:00:37', '2025-09-19 08:53:43', 'Bug fix', 'pending', 10);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (3, 'completed', '2025-04-15 01:20:01', '2025-02-09 22:30:05', '2025-11-02 04:08:54', 'Security patch', 'testing', 6);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (14, 'completed', '2025-12-16 09:24:54', '2025-09-24 13:04:15', '2025-11-13 02:21:15', 'Server maintenance', 'not available', 8);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (8, 'waiting for approval', '2025-05-04 06:03:37', '2025-07-04 11:48:33', '2025-09-01 02:49:49', 'Performance optimization', 'in progress', 7);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (13, 'on hold', '2025-12-11 20:05:29', '2025-02-01 05:48:26', '2025-02-21 14:14:15', 'Documentation update', 'available', 2);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (15, 'approved', '2025-08-31 07:19:48', '2025-06-05 11:05:47', '2025-06-04 03:39:52', 'Performance optimization', 'not available', 1);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (4, 'in progress', '2025-08-10 21:07:47', '2025-11-12 13:55:29', '2025-10-25 22:38:59', 'Code refactoring', 'available', 9);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (13, 'on hold', '2025-11-09 20:38:01', '2025-04-16 15:11:18', '2025-12-06 15:42:03', 'Database migration', 'under review', 7);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (2, 'waiting for approval', '2025-07-04 11:15:05', '2025-01-30 15:21:21', '2025-05-12 09:33:31', 'Bug fix', 'testing', 7);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (20, 'in progress', '2025-04-11 21:47:19', '2025-01-30 14:49:12', '2025-02-20 23:51:49', 'Database migration', 'completed', 9);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (6, 'on hold', '2025-02-25 19:27:31', '2025-09-12 07:14:56', '2025-06-13 23:24:33', 'Server maintenance', 'in progress', 3);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (14, 'cancelled', '2025-06-11 20:08:22', '2025-05-10 14:43:21', '2025-01-16 02:52:06', 'Documentation update', 'testing', 6);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (8, 'cancelled', '2025-06-09 22:37:13', '2025-01-11 09:20:26', '2024-12-31 01:34:46', 'Server maintenance', 'pending', 9);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (18, 'approved', '2025-02-20 07:07:10', '2025-07-13 19:16:56', '2025-12-05 07:28:20', 'Feature enhancement', 'testing', 4);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (3, 'needs review', '2025-10-21 14:59:50', '2025-11-20 09:51:47', '2025-01-05 02:52:11', 'Security patch', 'pending', 2);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (20, 'failed', '2025-01-09 15:04:42', '2025-08-20 21:47:30', '2025-06-03 07:26:55', 'API integration', 'testing', 8);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (2, 'waiting for approval', '2025-07-21 12:17:42', '2025-10-03 10:59:16', '2025-01-29 01:18:32', 'Documentation update', 'cancelled', 8);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (7, 'failed', '2025-12-16 15:04:36', '2025-08-10 05:23:08', '2025-07-03 23:37:02', 'Security patch', 'scheduled', 10);
=======
insert into studentEmails (studentID, email) values (9, 'bpallin0@census.gov');
insert into studentEmails (studentID, email) values (10, 'pvial1@indiegogo.com');
insert into studentEmails (studentID, email) values (19, 'ccolton2@moonfruit.com');
insert into studentEmails (studentID, email) values (4, 'bmcilmorow3@businessweek.com');
insert into studentEmails (studentID, email) values (24, 'mvanacci4@jalbum.net');
insert into studentEmails (studentID, email) values (28, 'anares5@aol.com');
insert into studentEmails (studentID, email) values (15, 'lanlay6@edublogs.org');
insert into studentEmails (studentID, email) values (20, 'jbanghe7@themeforest.net');
insert into studentEmails (studentID, email) values (18, 'timpy8@moonfruit.com');
insert into studentEmails (studentID, email) values (19, 'mwooffinden9@imageshack.us');
insert into studentEmails (studentID, email) values (24, 'clydona@bing.com');
insert into studentEmails (studentID, email) values (15, 'owearnb@npr.org');
insert into studentEmails (studentID, email) values (16, 'kdimitrovc@dailymotion.com');
insert into studentEmails (studentID, email) values (17, 'sbowserd@phoca.cz');
insert into studentEmails (studentID, email) values (26, 'rtitee@google.co.uk');
insert into studentEmails (studentID, email) values (15, 'rwodelandf@cdc.gov');
insert into studentEmails (studentID, email) values (28, 'sdabsg@reuters.com');
insert into studentEmails (studentID, email) values (5, 'lcordreyh@dion.ne.jp');
insert into studentEmails (studentID, email) values (34, 'gderingi@weebly.com');
insert into studentEmails (studentID, email) values (7, 'jainleyj@slate.com');
insert into studentEmails (studentID, email) values (1, 'clavallek@twitpic.com');
insert into studentEmails (studentID, email) values (28, 'cbarrarl@discuz.net');
insert into studentEmails (studentID, email) values (22, 'jhebbesm@msu.edu');
insert into studentEmails (studentID, email) values (28, 'alemarchantn@redcross.org');
insert into studentEmails (studentID, email) values (10, 'dminogueo@ft.com');
insert into studentEmails (studentID, email) values (16, 'rbraneyp@google.ru');
insert into studentEmails (studentID, email) values (2, 'hralestoneq@vimeo.com');
insert into studentEmails (studentID, email) values (12, 'ddogetr@typepad.com');
insert into studentEmails (studentID, email) values (32, 'treedicks@histats.com');
insert into studentEmails (studentID, email) values (9, 'mfowldst@netvibes.com');
insert into studentEmails (studentID, email) values (29, 'aocallaghanu@alexa.com');
insert into studentEmails (studentID, email) values (20, 'uyellandv@vimeo.com');
insert into studentEmails (studentID, email) values (2, 'aleverentzw@indiegogo.com');
insert into studentEmails (studentID, email) values (14, 'ssummerillx@bloglines.com');
insert into studentEmails (studentID, email) values (11, 'mbraidy@apple.com');
insert into studentEmails (studentID, email) values (6, 'qkrolakz@japanpost.jp');
insert into studentEmails (studentID, email) values (10, 'aogg10@admin.ch');
insert into studentEmails (studentID, email) values (4, 'blinnard11@free.fr');
insert into studentEmails (studentID, email) values (31, 'mflament12@jugem.jp');
insert into studentEmails (studentID, email) values (24, 'jretchford13@liveinternet.ru');
insert into studentEmails (studentID, email) values (30, 'speers14@google.com.hk');
insert into studentEmails (studentID, email) values (25, 'rpay15@reference.com');
insert into studentEmails (studentID, email) values (28, 'bskellen16@amazon.co.jp');
insert into studentEmails (studentID, email) values (18, 'pdeinert17@cmu.edu');
insert into studentEmails (studentID, email) values (20, 'mvanderweedenburg18@wikipedia.org');
insert into studentEmails (studentID, email) values (15, 'mmcgeouch19@diigo.com');
insert into studentEmails (studentID, email) values (7, 'nreskelly1a@last.fm');
insert into studentEmails (studentID, email) values (21, 'cingree1b@jiathis.com');
insert into studentEmails (studentID, email) values (16, 'dblankett1c@about.com');
insert into studentEmails (studentID, email) values (25, 'cbuten1d@youtube.com');
insert into studentEmails (studentID, email) values (33, 'smurray1e@earthlink.net');
insert into studentEmails (studentID, email) values (19, 'bbuzza1f@booking.com');
insert into studentEmails (studentID, email) values (22, 'dhubeaux1g@google.pl');
insert into studentEmails (studentID, email) values (12, 'cfirth1h@wiley.com');
insert into studentEmails (studentID, email) values (1, 'cgegg1i@biblegateway.com');
insert into studentEmails (studentID, email) values (26, 'jgermain1j@mail.ru');
insert into studentEmails (studentID, email) values (17, 'ldorman1k@europa.eu');
insert into studentEmails (studentID, email) values (19, 'ajarmyn1l@prlog.org');
insert into studentEmails (studentID, email) values (26, 'cscogin1m@latimes.com');
insert into studentEmails (studentID, email) values (20, 'skingsland1n@naver.com');
insert into studentEmails (studentID, email) values (15, 'lbasnett1o@techcrunch.com');
insert into studentEmails (studentID, email) values (34, 'rtacon1p@mysql.com');
insert into studentEmails (studentID, email) values (6, 'merickson1q@baidu.com');
insert into studentEmails (studentID, email) values (22, 'bmurthwaite1r@51.la');
insert into studentEmails (studentID, email) values (19, 'jnutton1s@simplemachines.org');
insert into studentEmails (studentID, email) values (5, 'rblackadder1t@prnewswire.com');
insert into studentEmails (studentID, email) values (15, 'gflegg1u@so-net.ne.jp');
insert into studentEmails (studentID, email) values (2, 'fmcnickle1v@fotki.com');
insert into studentEmails (studentID, email) values (35, 'rsilliman1w@craigslist.org');
insert into studentEmails (studentID, email) values (4, 'tjoe1x@oakley.com');
insert into studentEmails (studentID, email) values (5, 'dlubbock1y@smh.com.au');
insert into studentEmails (studentID, email) values (5, 'lcaves1z@newyorker.com');
insert into studentEmails (studentID, email) values (31, 'bbargery20@indiatimes.com');
insert into studentEmails (studentID, email) values (22, 'gderr21@ucla.edu');
insert into studentEmails (studentID, email) values (35, 'wipgrave22@paypal.com');
insert into studentEmails (studentID, email) values (20, 'lcarrol23@usgs.gov');
insert into studentEmails (studentID, email) values (8, 'goverpool24@fda.gov');
insert into studentEmails (studentID, email) values (3, 'aivkovic25@usatoday.com');
insert into studentEmails (studentID, email) values (12, 'dsimondson26@google.co.jp');
insert into studentEmails (studentID, email) values (33, 'rwoollin27@chronoengine.com');
insert into studentEmails (studentID, email) values (3, 'drushbrook28@utexas.edu');
insert into studentEmails (studentID, email) values (5, 'nmortlock29@nsw.gov.au');
insert into studentEmails (studentID, email) values (18, 'achamberlaine2a@rediff.com');
insert into studentEmails (studentID, email) values (8, 'gmauger2b@wisc.edu');
insert into studentEmails (studentID, email) values (28, 'zmorefield2c@walmart.com');
insert into studentEmails (studentID, email) values (3, 'rtoopin2d@diigo.com');
insert into studentEmails (studentID, email) values (11, 'cgreer2e@imageshack.us');
insert into studentEmails (studentID, email) values (7, 'ebrokenshaw2f@miibeian.gov.cn');
insert into studentEmails (studentID, email) values (21, 'nruggier2g@friendfeed.com');
insert into studentEmails (studentID, email) values (10, 'jdunbabin2h@patch.com');
insert into studentEmails (studentID, email) values (19, 'ebathoe2i@tamu.edu');
insert into studentEmails (studentID, email) values (12, 'eschwandermann2j@nyu.edu');
insert into studentEmails (studentID, email) values (26, 'dmulholland2k@taobao.com');
insert into studentEmails (studentID, email) values (19, 'cdunmuir2l@artisteer.com');
insert into studentEmails (studentID, email) values (1, 'cvertey2m@blogger.com');
insert into studentEmails (studentID, email) values (4, 'dsaterweyte2n@dropbox.com');
insert into studentEmails (studentID, email) values (2, 'gpapez2o@ehow.com');
insert into studentEmails (studentID, email) values (32, 'jmcquilkin2p@arstechnica.com');
insert into studentEmails (studentID, email) values (12, 'abeddows2q@smugmug.com');
insert into studentEmails (studentID, email) values (2, 'lcarnew2r@paypal.com');
insert into studentEmails (studentID, email) values (10, 'kwehden2s@naver.com');
insert into studentEmails (studentID, email) values (3, 'cwhiskerd2t@skype.com');
insert into studentEmails (studentID, email) values (23, 'bwind2u@reverbnation.com');
insert into studentEmails (studentID, email) values (17, 'llyddon2v@clickbank.net');
insert into studentEmails (studentID, email) values (5, 'nfrondt2w@amazon.de');
insert into studentEmails (studentID, email) values (4, 'bhawking2x@sourceforge.net');
insert into studentEmails (studentID, email) values (6, 'msteabler2y@businessweek.com');
insert into studentEmails (studentID, email) values (30, 'ehull2z@bluehost.com');
insert into studentEmails (studentID, email) values (26, 'oknath30@drupal.org');
insert into studentEmails (studentID, email) values (15, 'ctort31@apache.org');
insert into studentEmails (studentID, email) values (16, 'kpfertner32@deliciousdays.com');
insert into studentEmails (studentID, email) values (10, 'ldavidesco33@vkontakte.ru');
insert into studentEmails (studentID, email) values (9, 'agooley34@cornell.edu');
insert into studentEmails (studentID, email) values (8, 'rsine35@scribd.com');
insert into studentEmails (studentID, email) values (14, 'ahamil36@networkadvertising.org');
insert into studentEmails (studentID, email) values (22, 'emorpeth37@rakuten.co.jp');
insert into studentEmails (studentID, email) values (21, 'jchilcotte38@va.gov');
insert into studentEmails (studentID, email) values (7, 'sluckey39@arstechnica.com');
insert into studentEmails (studentID, email) values (14, 'amixer3a@yellowpages.com');
insert into studentEmails (studentID, email) values (15, 'vfransoni3b@army.mil');
insert into studentEmails (studentID, email) values (35, 'ccauldfield3c@sciencedirect.com');
insert into studentEmails (studentID, email) values (10, 'mhopkynson3d@example.com');
insert into studentEmails (studentID, email) values (12, 'rskokoe3e@cocolog-nifty.com');
insert into studentEmails (studentID, email) values (14, 'lheardman3f@networkadvertising.org');
insert into studentEmails (studentID, email) values (20, 'bboardman3g@disqus.com');
insert into studentEmails (studentID, email) values (35, 'mfowells3h@bigcartel.com');
insert into studentEmails (studentID, email) values (4, 'wmaudsley3i@epa.gov');
insert into studentEmails (studentID, email) values (17, 'rlabroue3j@chicagotribune.com');
insert into studentEmails (studentID, email) values (2, 'gcamden3k@google.co.jp');
insert into studentEmails (studentID, email) values (15, 'blunk3l@blogs.com');
;


-- 9. update
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (10, 'pending', '2025-08-27 17:07:35', '2025-11-11 18:46:28', '2025-01-04 03:08:55', 'Database migration', 'completed', 1);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (12, 'in progress', '2025-07-06 10:58:53', '2025-03-01 11:58:52', '2025-08-14 00:05:42', 'Database migration', 'in progress', 2);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (18, 'approved', '2025-07-25 00:34:10', '2025-05-24 14:39:13', '2025-08-05 23:17:31', 'Security patch', 'testing', 3);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (16, 'approved', '2025-08-15 22:25:38', '2025-09-20 12:58:39', '2025-12-02 18:32:08', 'User interface update', 'completed', 4);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (5, 'pending', '2025-06-17 04:09:00', '2025-11-09 03:44:01', '2025-07-28 05:36:58', 'Documentation update', 'delayed', 5);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (13, 'waiting for approval', '2025-09-07 20:04:21', '2025-10-13 12:52:29', '2025-06-09 17:08:29', 'Feature enhancement', 'scheduled', 6);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (2, 'cancelled', '2025-02-03 19:56:11', '2025-08-13 19:36:57', '2025-03-15 00:51:50', 'User interface update', 'not available', 7);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (13, 'approved', '2025-06-27 20:25:11', '2025-07-14 10:42:13', '2025-03-06 05:16:41', 'User interface update', 'scheduled', 8);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (17, 'waiting for approval', '2025-08-02 13:44:20', '2025-12-18 01:10:59', '2025-04-03 01:07:48', 'Feature enhancement', 'completed', 9);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (9, 'waiting for approval', '2025-12-17 01:23:13', '2025-03-19 01:46:43', '2025-03-27 16:18:32', 'Code refactoring', 'completed', 10);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (4, 'cancelled', '2025-12-14 00:16:43', '2025-07-25 05:35:32', '2025-03-23 21:28:18', 'Server maintenance', 'not available', 11);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (9, 'in progress', '2025-03-16 00:48:43', '2025-10-14 12:52:24', '2025-11-27 04:59:19', 'Database migration', 'under review', 12);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (5, 'completed', '2025-05-13 04:44:29', '2025-04-06 18:04:06', '2025-04-12 03:00:21', 'API integration', 'under review', 13);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (9, 'on hold', '2025-02-24 22:26:56', '2025-10-08 03:08:51', '2025-06-01 03:47:07', 'Code refactoring', 'not available', 14);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (2, 'waiting for approval', '2025-10-27 21:58:11', '2025-12-22 22:00:26', '2025-06-04 11:21:15', 'Server maintenance', 'available', 15);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (12, 'completed', '2025-01-24 23:44:32', '2025-02-18 09:15:22', '2025-02-22 06:52:52', 'Documentation update', 'cancelled', 16);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (16, 'waiting for approval', '2025-04-09 03:10:25', '2025-04-18 11:21:52', '2025-11-24 00:22:36', 'Bug fix', 'available', 17);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (19, 'failed', '2025-08-17 14:34:54', '2025-10-15 15:05:27', '2025-11-08 04:16:17', 'Documentation update', 'pending', 18);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (11, 'pending', '2025-07-03 15:40:44', '2025-06-11 19:55:27', '2025-12-25 10:19:54', 'Database migration', 'available', 19);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (4, 'needs review', '2025-04-22 09:58:28', '2025-01-06 15:00:43', '2025-07-03 18:37:31', 'Code refactoring', 'testing', 20);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (3, 'failed', '2025-10-29 10:37:27', '2025-07-27 08:18:50', '2025-07-19 12:53:27', 'Database migration', 'testing', 21);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (15, 'pending', '2025-05-26 16:52:52', '2025-04-30 09:41:28', '2025-09-14 16:53:53', 'Performance optimization', 'pending', 22);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (9, 'approved', '2025-01-07 04:50:41', '2025-09-08 07:00:37', '2025-09-19 08:53:43', 'Bug fix', 'pending', 23);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (3, 'completed', '2025-04-15 01:20:01', '2025-02-09 22:30:05', '2025-11-02 04:08:54', 'Security patch', 'testing', 24);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (14, 'completed', '2025-12-16 09:24:54', '2025-09-24 13:04:15', '2025-11-13 02:21:15', 'Server maintenance', 'not available', 25);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (8, 'waiting for approval', '2025-05-04 06:03:37', '2025-07-04 11:48:33', '2025-09-01 02:49:49', 'Performance optimization', 'in progress', 26);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (13, 'on hold', '2025-12-11 20:05:29', '2025-02-01 05:48:26', '2025-02-21 14:14:15', 'Documentation update', 'available', 27);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (15, 'approved', '2025-08-31 07:19:48', '2025-06-05 11:05:47', '2025-06-04 03:39:52', 'Performance optimization', 'not available', 28);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (4, 'in progress', '2025-08-10 21:07:47', '2025-11-12 13:55:29', '2025-10-25 22:38:59', 'Code refactoring', 'available', 29);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (13, 'on hold', '2025-11-09 20:38:01', '2025-04-16 15:11:18', '2025-12-06 15:42:03', 'Database migration', 'under review', 30);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (2, 'waiting for approval', '2025-07-04 11:15:05', '2025-01-30 15:21:21', '2025-05-12 09:33:31', 'Bug fix', 'testing', 31);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (20, 'in progress', '2025-04-11 21:47:19', '2025-01-30 14:49:12', '2025-02-20 23:51:49', 'Database migration', 'completed', 32);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (6, 'on hold', '2025-02-25 19:27:31', '2025-09-12 07:14:56', '2025-06-13 23:24:33', 'Server maintenance', 'in progress', 33);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (14, 'cancelled', '2025-06-11 20:08:22', '2025-05-10 14:43:21', '2025-01-16 02:52:06', 'Documentation update', 'testing', 34);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (8, 'cancelled', '2025-06-09 22:37:13', '2025-01-11 09:20:26', '2024-12-31 01:34:46', 'Server maintenance', 'pending', 35);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (18, 'approved', '2025-02-20 07:07:10', '2025-07-13 19:16:56', '2025-12-05 07:28:20', 'Feature enhancement', 'testing', 36);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (3, 'needs review', '2025-10-21 14:59:50', '2025-11-20 09:51:47', '2025-01-05 02:52:11', 'Security patch', 'pending', 37);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (20, 'failed', '2025-01-09 15:04:42', '2025-08-20 21:47:30', '2025-06-03 07:26:55', 'API integration', 'testing', 38);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (2, 'waiting for approval', '2025-07-21 12:17:42', '2025-10-03 10:59:16', '2025-01-29 01:18:32', 'Documentation update', 'cancelled', 39);
insert into `update` (adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability, updateID) values (7, 'failed', '2025-12-16 15:04:36', '2025-08-10 05:23:08', '2025-07-03 23:37:02', 'Security patch', 'scheduled', 40);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72

-- 10. eboardMember
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (1, 12, 35, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (2, 5, 2, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (3, 8, 28, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (4, 12, 8, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (5, 26, 14, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (6, 8, 5, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (7, 8, 2, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (8, 33, 26, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (9, 23, 19, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (10, 11, 24, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (11, 9, 10, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (12, 26, 8, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (13, 20, 20, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (14, 8, 5, 'Treasurer');
<<<<<<< HEAD
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (15, 17, 18, 'Vice President');
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (16, 11, 26, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (17, 35, 22, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (18, 22, 35, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (19, 6, 15, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (20, 21, 9, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (21, 27, 12, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (22, 26, 30, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (23, 3, 34, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (24, 31, 1, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (25, 27, 4, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (26, 32, 5, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (27, 23, 33, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (28, 35, 28, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (29, 23, 19, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (30, 33, 9, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (31, 18, 11, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (32, 10, 8, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (33, 3, 24, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (34, 6, 1, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (35, 19, 4, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (36, 20, 24, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (37, 27, 2, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (38, 18, 5, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (39, 26, 10, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (40, 27, 4, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (41, 20, 2, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (42, 10, 8, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (43, 2, 9, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (44, 26, 16, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (45, 3, 35, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (46, 29, 22, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (47, 20, 15, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (48, 9, 12, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (49, 30, 4, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (50, 28, 23, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (51, 9, 6, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (52, 31, 27, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (53, 14, 32, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (54, 9, 4, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (55, 27, 30, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (56, 15, 21, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (57, 13, 13, 'Vice President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (58, 20, 20, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (59, 1, 14, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (60, 17, 30, 'Secretary');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (61, 29, 21, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (62, 31, 25, 'President');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (63, 2, 35, 'Treasurer');
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (64, 11, 3, 'Treasurer');
<<<<<<< HEAD
insert into eboardMember (eboardMemberID, studentID, eboardID, position) values (65, 24, 18, 'Treasurer');

-- 11. clubCategories
insert into clubCategories (clubID, categoryID) values (30, 1);
=======

-- 11. clubCategories
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into clubCategories (clubID, categoryID) values (3, 6);
insert into clubCategories (clubID, categoryID) values (10, 4);
insert into clubCategories (clubID, categoryID) values (20, 11);
insert into clubCategories (clubID, categoryID) values (5, 14);
insert into clubCategories (clubID, categoryID) values (14, 4);
insert into clubCategories (clubID, categoryID) values (6, 6);
insert into clubCategories (clubID, categoryID) values (4, 6);
insert into clubCategories (clubID, categoryID) values (29, 13);
insert into clubCategories (clubID, categoryID) values (27, 5);
insert into clubCategories (clubID, categoryID) values (10, 9);
insert into clubCategories (clubID, categoryID) values (26, 3);
insert into clubCategories (clubID, categoryID) values (21, 6);
insert into clubCategories (clubID, categoryID) values (19, 6);
insert into clubCategories (clubID, categoryID) values (34, 2);
insert into clubCategories (clubID, categoryID) values (18, 5);
insert into clubCategories (clubID, categoryID) values (24, 13);
insert into clubCategories (clubID, categoryID) values (19, 15);
insert into clubCategories (clubID, categoryID) values (2, 8);
insert into clubCategories (clubID, categoryID) values (18, 7);
insert into clubCategories (clubID, categoryID) values (31, 12);
insert into clubCategories (clubID, categoryID) values (8, 10);
insert into clubCategories (clubID, categoryID) values (25, 14);
insert into clubCategories (clubID, categoryID) values (7, 13);
insert into clubCategories (clubID, categoryID) values (16, 8);
insert into clubCategories (clubID, categoryID) values (15, 6);
insert into clubCategories (clubID, categoryID) values (19, 4);
insert into clubCategories (clubID, categoryID) values (26, 1);
insert into clubCategories (clubID, categoryID) values (25, 8);
insert into clubCategories (clubID, categoryID) values (32, 4);
insert into clubCategories (clubID, categoryID) values (27, 9);
insert into clubCategories (clubID, categoryID) values (24, 14);
insert into clubCategories (clubID, categoryID) values (2, 15);
insert into clubCategories (clubID, categoryID) values (24, 4);
insert into clubCategories (clubID, categoryID) values (16, 11);
insert into clubCategories (clubID, categoryID) values (1, 2);
insert into clubCategories (clubID, categoryID) values (1, 3);
insert into clubCategories (clubID, categoryID) values (1, 7);
insert into clubCategories (clubID, categoryID) values (2, 1);
insert into clubCategories (clubID, categoryID) values (2, 3);
insert into clubCategories (clubID, categoryID) values (3, 1);
insert into clubCategories (clubID, categoryID) values (3, 3);
insert into clubCategories (clubID, categoryID) values (3, 7);
insert into clubCategories (clubID, categoryID) values (4, 2);
insert into clubCategories (clubID, categoryID) values (4, 4);
insert into clubCategories (clubID, categoryID) values (5, 2);
insert into clubCategories (clubID, categoryID) values (5, 4);
insert into clubCategories (clubID, categoryID) values (5, 7);
insert into clubCategories (clubID, categoryID) values (6, 2);
insert into clubCategories (clubID, categoryID) values (6, 4);
insert into clubCategories (clubID, categoryID) values (7, 2);
insert into clubCategories (clubID, categoryID) values (7, 8);
insert into clubCategories (clubID, categoryID) values (8, 1);
insert into clubCategories (clubID, categoryID) values (8, 3);
insert into clubCategories (clubID, categoryID) values (8, 7);
insert into clubCategories (clubID, categoryID) values (9, 1);
insert into clubCategories (clubID, categoryID) values (9, 3);
insert into clubCategories (clubID, categoryID) values (9, 7);
insert into clubCategories (clubID, categoryID) values (10, 13);
insert into clubCategories (clubID, categoryID) values (11, 2);
insert into clubCategories (clubID, categoryID) values (11, 4);
insert into clubCategories (clubID, categoryID) values (11, 7);
insert into clubCategories (clubID, categoryID) values (12, 2);
insert into clubCategories (clubID, categoryID) values (12, 7);
insert into clubCategories (clubID, categoryID) values (13, 2);
insert into clubCategories (clubID, categoryID) values (13, 3);
insert into clubCategories (clubID, categoryID) values (13, 7);
insert into clubCategories (clubID, categoryID) values (14, 1);
insert into clubCategories (clubID, categoryID) values (14, 3);
insert into clubCategories (clubID, categoryID) values (15, 2);
insert into clubCategories (clubID, categoryID) values (15, 4);
insert into clubCategories (clubID, categoryID) values (16, 2);
insert into clubCategories (clubID, categoryID) values (17, 1);
insert into clubCategories (clubID, categoryID) values (17, 3);
insert into clubCategories (clubID, categoryID) values (17, 7);
insert into clubCategories (clubID, categoryID) values (18, 13);
insert into clubCategories (clubID, categoryID) values (20, 2);
insert into clubCategories (clubID, categoryID) values (20, 8);
insert into clubCategories (clubID, categoryID) values (21, 2);
insert into clubCategories (clubID, categoryID) values (21, 4);
insert into clubCategories (clubID, categoryID) values (22, 13);
insert into clubCategories (clubID, categoryID) values (22, 8);
insert into clubCategories (clubID, categoryID) values (23, 2);
insert into clubCategories (clubID, categoryID) values (23, 4);
insert into clubCategories (clubID, categoryID) values (23, 6);
insert into clubCategories (clubID, categoryID) values (25, 13);
insert into clubCategories (clubID, categoryID) values (26, 13);
insert into clubCategories (clubID, categoryID) values (27, 2);
insert into clubCategories (clubID, categoryID) values (27, 4);
insert into clubCategories (clubID, categoryID) values (28, 13);
insert into clubCategories (clubID, categoryID) values (28, 8);
insert into clubCategories (clubID, categoryID) values (29, 2);
insert into clubCategories (clubID, categoryID) values (29, 3);
insert into clubCategories (clubID, categoryID) values (30, 13);
insert into clubCategories (clubID, categoryID) values (30, 8);
insert into clubCategories (clubID, categoryID) values (31, 2);
insert into clubCategories (clubID, categoryID) values (31, 4);
insert into clubCategories (clubID, categoryID) values (31, 6);
insert into clubCategories (clubID, categoryID) values (32, 2);
insert into clubCategories (clubID, categoryID) values (32, 7);
insert into clubCategories (clubID, categoryID) values (33, 1);
insert into clubCategories (clubID, categoryID) values (33, 3);
insert into clubCategories (clubID, categoryID) values (33, 7);
insert into clubCategories (clubID, categoryID) values (34, 7);
insert into clubCategories (clubID, categoryID) values (35, 2);
insert into clubCategories (clubID, categoryID) values (35, 3);
insert into clubCategories (clubID, categoryID) values (35, 7);
insert into clubCategories (clubID, categoryID) values (1, 4);
insert into clubCategories (clubID, categoryID) values (4, 8);
insert into clubCategories (clubID, categoryID) values (5, 10);
insert into clubCategories (clubID, categoryID) values (9, 10);
insert into clubCategories (clubID, categoryID) values (11, 8);
insert into clubCategories (clubID, categoryID) values (12, 4);
insert into clubCategories (clubID, categoryID) values (13, 4);
insert into clubCategories (clubID, categoryID) values (14, 7);
insert into clubCategories (clubID, categoryID) values (15, 7);
insert into clubCategories (clubID, categoryID) values (16, 4);
insert into clubCategories (clubID, categoryID) values (17, 4);
insert into clubCategories (clubID, categoryID) values (18, 8);
insert into clubCategories (clubID, categoryID) values (19, 2);
insert into clubCategories (clubID, categoryID) values (20, 15);
insert into clubCategories (clubID, categoryID) values (21, 8);
insert into clubCategories (clubID, categoryID) values (22, 15);
insert into clubCategories (clubID, categoryID) values (23, 8);
insert into clubCategories (clubID, categoryID) values (24, 2);
insert into clubCategories (clubID, categoryID) values (28, 15);
insert into clubCategories (clubID, categoryID) values (29, 7);
insert into clubCategories (clubID, categoryID) values (32, 8);
insert into clubCategories (clubID, categoryID) values (33, 4);
insert into clubCategories (clubID, categoryID) values (34, 4);

-- 12. clubEvents
<<<<<<< HEAD
insert into clubEvents (clubID, eventID) values (6, 18);
insert into clubEvents (clubID, eventID) values (31, 23);
insert into clubEvents (clubID, eventID) values (25, 17);
insert into clubEvents (clubID, eventID) values (29, 3);
=======
insert into clubEvents (clubID, eventID) values (6, 19);
insert into clubEvents (clubID, eventID) values (31, 24);
insert into clubEvents (clubID, eventID) values (25, 17);
insert into clubEvents (clubID, eventID) values (29, 4);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into clubEvents (clubID, eventID) values (4, 7);
insert into clubEvents (clubID, eventID) values (30, 28);
insert into clubEvents (clubID, eventID) values (18, 11);
insert into clubEvents (clubID, eventID) values (15, 3);
insert into clubEvents (clubID, eventID) values (34, 9);
insert into clubEvents (clubID, eventID) values (29, 3);
insert into clubEvents (clubID, eventID) values (16, 17);
insert into clubEvents (clubID, eventID) values (7, 33);
insert into clubEvents (clubID, eventID) values (18, 22);
insert into clubEvents (clubID, eventID) values (27, 30);
insert into clubEvents (clubID, eventID) values (33, 5);
insert into clubEvents (clubID, eventID) values (30, 25);
insert into clubEvents (clubID, eventID) values (19, 3);
insert into clubEvents (clubID, eventID) values (22, 34);
insert into clubEvents (clubID, eventID) values (21, 24);
insert into clubEvents (clubID, eventID) values (22, 35);
insert into clubEvents (clubID, eventID) values (3, 10);
insert into clubEvents (clubID, eventID) values (21, 18);
insert into clubEvents (clubID, eventID) values (11, 24);
insert into clubEvents (clubID, eventID) values (17, 25);
insert into clubEvents (clubID, eventID) values (3, 25);
insert into clubEvents (clubID, eventID) values (27, 2);
insert into clubEvents (clubID, eventID) values (25, 15);
insert into clubEvents (clubID, eventID) values (13, 17);
insert into clubEvents (clubID, eventID) values (33, 12);
insert into clubEvents (clubID, eventID) values (8, 8);
<<<<<<< HEAD
insert into clubEvents (clubID, eventID) values (33, 16);
insert into clubEvents (clubID, eventID) values (29, 5);
=======
insert into clubEvents (clubID, eventID) values (29, 2);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into clubEvents (clubID, eventID) values (35, 33);
insert into clubEvents (clubID, eventID) values (2, 21);
insert into clubEvents (clubID, eventID) values (22, 3);
insert into clubEvents (clubID, eventID) values (16, 21);
insert into clubEvents (clubID, eventID) values (5, 22);
insert into clubEvents (clubID, eventID) values (11, 18);
insert into clubEvents (clubID, eventID) values (21, 4);
insert into clubEvents (clubID, eventID) values (25, 20);
insert into clubEvents (clubID, eventID) values (29, 13);
insert into clubEvents (clubID, eventID) values (26, 8);
insert into clubEvents (clubID, eventID) values (11, 15);
insert into clubEvents (clubID, eventID) values (16, 31);
<<<<<<< HEAD
insert into clubEvents (clubID, eventID) values (27, 29);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into clubEvents (clubID, eventID) values (20, 1);
insert into clubEvents (clubID, eventID) values (15, 24);
insert into clubEvents (clubID, eventID) values (6, 27);
insert into clubEvents (clubID, eventID) values (15, 23);
insert into clubEvents (clubID, eventID) values (1, 17);
insert into clubEvents (clubID, eventID) values (29, 14);
insert into clubEvents (clubID, eventID) values (9, 12);
insert into clubEvents (clubID, eventID) values (9, 11);
insert into clubEvents (clubID, eventID) values (15, 6);
insert into clubEvents (clubID, eventID) values (9, 20);
insert into clubEvents (clubID, eventID) values (21, 34);
insert into clubEvents (clubID, eventID) values (23, 15);
insert into clubEvents (clubID, eventID) values (2, 22);
insert into clubEvents (clubID, eventID) values (35, 3);
<<<<<<< HEAD
insert into clubEvents (clubID, eventID) values (6, 18);
insert into clubEvents (clubID, eventID) values (19, 31);
insert into clubEvents (clubID, eventID) values (7, 7);
insert into clubEvents (clubID, eventID) values (27, 29);
insert into clubEvents (clubID, eventID) values (28, 11);
insert into clubEvents (clubID, eventID) values (24, 23);
insert into clubEvents (clubID, eventID) values (15, 22);
insert into clubEvents (clubID, eventID) values (29, 5);
=======
insert into clubEvents (clubID, eventID) values (6, 34);
insert into clubEvents (clubID, eventID) values (19, 31);
insert into clubEvents (clubID, eventID) values (7, 7);
insert into clubEvents (clubID, eventID) values (28, 11);
insert into clubEvents (clubID, eventID) values (24, 23);
insert into clubEvents (clubID, eventID) values (15, 22);
insert into clubEvents (clubID, eventID) values (29, 1);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into clubEvents (clubID, eventID) values (22, 32);
insert into clubEvents (clubID, eventID) values (7, 1);
insert into clubEvents (clubID, eventID) values (8, 31);
insert into clubEvents (clubID, eventID) values (34, 29);
insert into clubEvents (clubID, eventID) values (4, 12);
insert into clubEvents (clubID, eventID) values (22, 8);
insert into clubEvents (clubID, eventID) values (20, 34);
insert into clubEvents (clubID, eventID) values (3, 19);
insert into clubEvents (clubID, eventID) values (29, 34);
insert into clubEvents (clubID, eventID) values (33, 2);
insert into clubEvents (clubID, eventID) values (7, 34);
insert into clubEvents (clubID, eventID) values (29, 24);
insert into clubEvents (clubID, eventID) values (22, 30);
insert into clubEvents (clubID, eventID) values (1, 14);
insert into clubEvents (clubID, eventID) values (24, 10);
insert into clubEvents (clubID, eventID) values (30, 1);
insert into clubEvents (clubID, eventID) values (7, 3);
insert into clubEvents (clubID, eventID) values (29, 21);
insert into clubEvents (clubID, eventID) values (25, 7);
insert into clubEvents (clubID, eventID) values (33, 7);
insert into clubEvents (clubID, eventID) values (13, 12);
insert into clubEvents (clubID, eventID) values (27, 10);
insert into clubEvents (clubID, eventID) values (15, 32);
insert into clubEvents (clubID, eventID) values (20, 15);
insert into clubEvents (clubID, eventID) values (3, 31);
<<<<<<< HEAD
insert into clubEvents (clubID, eventID) values (20, 15);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into clubEvents (clubID, eventID) values (26, 21);
insert into clubEvents (clubID, eventID) values (35, 29);
insert into clubEvents (clubID, eventID) values (23, 12);
insert into clubEvents (clubID, eventID) values (19, 22);
insert into clubEvents (clubID, eventID) values (27, 31);
insert into clubEvents (clubID, eventID) values (32, 35);
insert into clubEvents (clubID, eventID) values (7, 16);
insert into clubEvents (clubID, eventID) values (13, 4);
insert into clubEvents (clubID, eventID) values (17, 32);
insert into clubEvents (clubID, eventID) values (3, 35);
insert into clubEvents (clubID, eventID) values (9, 9);
insert into clubEvents (clubID, eventID) values (32, 19);
<<<<<<< HEAD
insert into clubEvents (clubID, eventID) values (33, 16);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into clubEvents (clubID, eventID) values (33, 4);
insert into clubEvents (clubID, eventID) values (12, 16);
insert into clubEvents (clubID, eventID) values (22, 11);
insert into clubEvents (clubID, eventID) values (15, 12);
insert into clubEvents (clubID, eventID) values (27, 18);
insert into clubEvents (clubID, eventID) values (9, 13);
insert into clubEvents (clubID, eventID) values (23, 24);
insert into clubEvents (clubID, eventID) values (1, 30);
insert into clubEvents (clubID, eventID) values (34, 34);
insert into clubEvents (clubID, eventID) values (21, 14);
insert into clubEvents (clubID, eventID) values (23, 18);
insert into clubEvents (clubID, eventID) values (35, 11);
insert into clubEvents (clubID, eventID) values (2, 2);
insert into clubEvents (clubID, eventID) values (2, 27);
insert into clubEvents (clubID, eventID) values (23, 27);
insert into clubEvents (clubID, eventID) values (18, 5);
insert into clubEvents (clubID, eventID) values (22, 5);
insert into clubEvents (clubID, eventID) values (4, 22);
insert into clubEvents (clubID, eventID) values (34, 25);
insert into clubEvents (clubID, eventID) values (32, 11);
insert into clubEvents (clubID, eventID) values (15, 4);
insert into clubEvents (clubID, eventID) values (20, 25);
insert into clubEvents (clubID, eventID) values (31, 5);
insert into clubEvents (clubID, eventID) values (13, 18);


-- 13. studentJoins
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (187, 36, '2024-06-11');
insert into studentJoins (studentID, clubID, joinDate) values (174, 35, '2023-11-23');
insert into studentJoins (studentID, clubID, joinDate) values (50, 1, '2024-05-09');
insert into studentJoins (studentID, clubID, joinDate) values (54, 40, '2024-04-03');
insert into studentJoins (studentID, clubID, joinDate) values (119, 26, '2024-07-18');
insert into studentJoins (studentID, clubID, joinDate) values (91, 36, '2025-12-17');
=======
insert into studentJoins (studentID, clubID, joinDate) values (187, 30, '2024-06-11');
insert into studentJoins (studentID, clubID, joinDate) values (174, 35, '2023-11-23');
insert into studentJoins (studentID, clubID, joinDate) values (50, 1, '2024-05-09');
insert into studentJoins (studentID, clubID, joinDate) values (54, 30, '2024-04-03');
insert into studentJoins (studentID, clubID, joinDate) values (119, 26, '2024-07-18');
insert into studentJoins (studentID, clubID, joinDate) values (91, 35, '2025-12-17');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (191, 6, '2024-07-30');
insert into studentJoins (studentID, clubID, joinDate) values (37, 26, '2025-05-19');
insert into studentJoins (studentID, clubID, joinDate) values (55, 15, '2025-08-17');
insert into studentJoins (studentID, clubID, joinDate) values (133, 18, '2025-03-28');
insert into studentJoins (studentID, clubID, joinDate) values (149, 4, '2025-04-13');
insert into studentJoins (studentID, clubID, joinDate) values (52, 18, '2025-09-03');
insert into studentJoins (studentID, clubID, joinDate) values (162, 15, '2025-11-15');
insert into studentJoins (studentID, clubID, joinDate) values (148, 25, '2024-04-18');
insert into studentJoins (studentID, clubID, joinDate) values (138, 30, '2023-09-30');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (37, 36, '2023-02-05');
=======
insert into studentJoins (studentID, clubID, joinDate) values (37, 31, '2023-02-05');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (6, 23, '2025-04-08');
insert into studentJoins (studentID, clubID, joinDate) values (174, 34, '2025-01-05');
insert into studentJoins (studentID, clubID, joinDate) values (141, 20, '2024-03-19');
insert into studentJoins (studentID, clubID, joinDate) values (140, 27, '2025-04-24');
insert into studentJoins (studentID, clubID, joinDate) values (200, 1, '2023-05-14');
insert into studentJoins (studentID, clubID, joinDate) values (193, 21, '2025-12-06');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (130, 37, '2025-06-21');
insert into studentJoins (studentID, clubID, joinDate) values (112, 36, '2024-02-07');
=======
insert into studentJoins (studentID, clubID, joinDate) values (130, 35, '2025-06-21');
insert into studentJoins (studentID, clubID, joinDate) values (112, 35, '2024-02-07');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (161, 9, '2024-09-12');
insert into studentJoins (studentID, clubID, joinDate) values (78, 17, '2025-10-16');
insert into studentJoins (studentID, clubID, joinDate) values (145, 10, '2023-04-17');
insert into studentJoins (studentID, clubID, joinDate) values (86, 9, '2023-04-03');
insert into studentJoins (studentID, clubID, joinDate) values (142, 31, '2024-08-25');
insert into studentJoins (studentID, clubID, joinDate) values (184, 13, '2024-03-05');
insert into studentJoins (studentID, clubID, joinDate) values (52, 15, '2025-06-21');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (186, 39, '2024-03-29');
insert into studentJoins (studentID, clubID, joinDate) values (90, 15, '2024-05-07');
insert into studentJoins (studentID, clubID, joinDate) values (184, 32, '2025-07-05');
insert into studentJoins (studentID, clubID, joinDate) values (25, 39, '2024-11-18');
insert into studentJoins (studentID, clubID, joinDate) values (84, 5, '2023-12-13');
insert into studentJoins (studentID, clubID, joinDate) values (67, 36, '2025-03-27');
insert into studentJoins (studentID, clubID, joinDate) values (44, 32, '2023-08-19');
insert into studentJoins (studentID, clubID, joinDate) values (135, 18, '2024-07-30');
insert into studentJoins (studentID, clubID, joinDate) values (121, 2, '2024-12-19');
insert into studentJoins (studentID, clubID, joinDate) values (18, 18, '2024-03-10');
insert into studentJoins (studentID, clubID, joinDate) values (198, 16, '2022-12-17');
insert into studentJoins (studentID, clubID, joinDate) values (164, 14, '2025-10-06');
=======
insert into studentJoins (studentID, clubID, joinDate) values (186, 35, '2024-03-29');
insert into studentJoins (studentID, clubID, joinDate) values (90, 15, '2024-05-07');
insert into studentJoins (studentID, clubID, joinDate) values (184, 32, '2025-07-05');
insert into studentJoins (studentID, clubID, joinDate) values (25, 13, '2024-11-18');
insert into studentJoins (studentID, clubID, joinDate) values (84, 5, '2023-12-13');
insert into studentJoins (studentID, clubID, joinDate) values (67, 35, '2025-03-27');
insert into studentJoins (studentID, clubID, joinDate) values (44, 32, '2023-08-19');
insert into studentJoins (studentID, clubID, joinDate) values (135, 18, '2024-07-30');
insert into studentJoins (studentID, clubID, joinDate) values (121, 2, '2024-12-19');
insert into studentJoins (studentID, clubID, joinDate) values (198, 16, '2022-12-17');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (141, 8, '2025-05-21');
insert into studentJoins (studentID, clubID, joinDate) values (74, 24, '2023-09-02');
insert into studentJoins (studentID, clubID, joinDate) values (10, 7, '2024-09-29');
insert into studentJoins (studentID, clubID, joinDate) values (80, 27, '2024-07-21');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (176, 36, '2025-01-11');
=======
insert into studentJoins (studentID, clubID, joinDate) values (176, 12, '2025-01-11');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (127, 15, '2024-04-29');
insert into studentJoins (studentID, clubID, joinDate) values (55, 4, '2023-08-24');
insert into studentJoins (studentID, clubID, joinDate) values (13, 26, '2022-10-17');
insert into studentJoins (studentID, clubID, joinDate) values (164, 27, '2022-09-24');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (133, 39, '2024-11-25');
=======
insert into studentJoins (studentID, clubID, joinDate) values (133, 31, '2024-11-25');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (125, 7, '2025-06-14');
insert into studentJoins (studentID, clubID, joinDate) values (150, 23, '2024-05-18');
insert into studentJoins (studentID, clubID, joinDate) values (177, 4, '2025-10-06');
insert into studentJoins (studentID, clubID, joinDate) values (72, 2, '2024-09-02');
insert into studentJoins (studentID, clubID, joinDate) values (30, 3, '2024-07-01');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (36, 40, '2023-11-20');
=======
insert into studentJoins (studentID, clubID, joinDate) values (36, 12, '2023-11-20');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (200, 3, '2023-08-10');
insert into studentJoins (studentID, clubID, joinDate) values (116, 2, '2022-11-06');
insert into studentJoins (studentID, clubID, joinDate) values (179, 1, '2024-02-25');
insert into studentJoins (studentID, clubID, joinDate) values (1, 4, '2024-09-19');
insert into studentJoins (studentID, clubID, joinDate) values (41, 9, '2025-02-27');
insert into studentJoins (studentID, clubID, joinDate) values (70, 5, '2025-12-09');
insert into studentJoins (studentID, clubID, joinDate) values (51, 19, '2025-10-31');
insert into studentJoins (studentID, clubID, joinDate) values (153, 6, '2025-12-13');
insert into studentJoins (studentID, clubID, joinDate) values (120, 18, '2023-06-16');
insert into studentJoins (studentID, clubID, joinDate) values (115, 8, '2024-07-16');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (164, 14, '2023-09-10');
insert into studentJoins (studentID, clubID, joinDate) values (157, 13, '2023-02-11');
insert into studentJoins (studentID, clubID, joinDate) values (18, 18, '2023-03-20');
insert into studentJoins (studentID, clubID, joinDate) values (137, 37, '2025-11-22');
=======
insert into studentJoins (studentID, clubID, joinDate) values (157, 13, '2023-02-11');
insert into studentJoins (studentID, clubID, joinDate) values (18, 18, '2023-03-20');
insert into studentJoins (studentID, clubID, joinDate) values (137, 10, '2025-11-22');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (119, 24, '2025-04-06');
insert into studentJoins (studentID, clubID, joinDate) values (167, 26, '2025-04-02');
insert into studentJoins (studentID, clubID, joinDate) values (45, 11, '2025-07-03');
insert into studentJoins (studentID, clubID, joinDate) values (127, 24, '2023-07-20');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (153, 37, '2023-04-20');
=======
insert into studentJoins (studentID, clubID, joinDate) values (153, 13, '2023-04-20');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (21, 26, '2023-05-05');
insert into studentJoins (studentID, clubID, joinDate) values (177, 2, '2024-03-24');
insert into studentJoins (studentID, clubID, joinDate) values (74, 20, '2025-04-05');
insert into studentJoins (studentID, clubID, joinDate) values (103, 31, '2025-06-01');
insert into studentJoins (studentID, clubID, joinDate) values (196, 6, '2023-06-15');
insert into studentJoins (studentID, clubID, joinDate) values (189, 24, '2022-08-20');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (97, 36, '2025-01-31');
=======
insert into studentJoins (studentID, clubID, joinDate) values (97, 23, '2025-01-31');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (173, 29, '2023-11-08');
insert into studentJoins (studentID, clubID, joinDate) values (32, 10, '2025-11-29');
insert into studentJoins (studentID, clubID, joinDate) values (32, 29, '2025-07-05');
insert into studentJoins (studentID, clubID, joinDate) values (142, 34, '2024-05-19');
insert into studentJoins (studentID, clubID, joinDate) values (191, 15, '2022-09-20');
insert into studentJoins (studentID, clubID, joinDate) values (147, 11, '2025-06-21');
insert into studentJoins (studentID, clubID, joinDate) values (140, 12, '2025-06-14');
insert into studentJoins (studentID, clubID, joinDate) values (147, 33, '2024-01-11');
insert into studentJoins (studentID, clubID, joinDate) values (15, 5, '2025-04-22');
insert into studentJoins (studentID, clubID, joinDate) values (72, 18, '2023-12-03');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (66, 39, '2022-10-13');
insert into studentJoins (studentID, clubID, joinDate) values (84, 39, '2023-11-03');
=======
insert into studentJoins (studentID, clubID, joinDate) values (66, 27, '2022-10-13');
insert into studentJoins (studentID, clubID, joinDate) values (84, 28, '2023-11-03');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (68, 32, '2025-09-15');
insert into studentJoins (studentID, clubID, joinDate) values (188, 11, '2024-01-24');
insert into studentJoins (studentID, clubID, joinDate) values (161, 30, '2023-08-21');
insert into studentJoins (studentID, clubID, joinDate) values (95, 6, '2022-12-28');
insert into studentJoins (studentID, clubID, joinDate) values (161, 17, '2025-09-11');
insert into studentJoins (studentID, clubID, joinDate) values (125, 23, '2022-12-02');
insert into studentJoins (studentID, clubID, joinDate) values (60, 16, '2025-11-27');
insert into studentJoins (studentID, clubID, joinDate) values (6, 34, '2022-11-09');
insert into studentJoins (studentID, clubID, joinDate) values (69, 35, '2024-10-10');
insert into studentJoins (studentID, clubID, joinDate) values (57, 27, '2025-11-12');
insert into studentJoins (studentID, clubID, joinDate) values (40, 27, '2022-12-10');
insert into studentJoins (studentID, clubID, joinDate) values (130, 4, '2025-02-27');
insert into studentJoins (studentID, clubID, joinDate) values (43, 29, '2024-12-02');
insert into studentJoins (studentID, clubID, joinDate) values (26, 35, '2022-09-29');
insert into studentJoins (studentID, clubID, joinDate) values (155, 3, '2024-09-30');
insert into studentJoins (studentID, clubID, joinDate) values (55, 10, '2025-02-01');
insert into studentJoins (studentID, clubID, joinDate) values (124, 28, '2024-06-28');
insert into studentJoins (studentID, clubID, joinDate) values (106, 8, '2023-01-05');
insert into studentJoins (studentID, clubID, joinDate) values (87, 9, '2023-03-08');
insert into studentJoins (studentID, clubID, joinDate) values (14, 18, '2025-07-06');
insert into studentJoins (studentID, clubID, joinDate) values (108, 33, '2024-05-12');
insert into studentJoins (studentID, clubID, joinDate) values (149, 29, '2023-04-28');
insert into studentJoins (studentID, clubID, joinDate) values (65, 6, '2024-04-24');
insert into studentJoins (studentID, clubID, joinDate) values (180, 20, '2023-10-19');
insert into studentJoins (studentID, clubID, joinDate) values (76, 23, '2024-12-29');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (97, 40, '2024-06-09');
=======
insert into studentJoins (studentID, clubID, joinDate) values (97, 18, '2024-06-09');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (41, 2, '2022-10-05');
insert into studentJoins (studentID, clubID, joinDate) values (111, 9, '2023-09-06');
insert into studentJoins (studentID, clubID, joinDate) values (168, 28, '2025-12-05');
insert into studentJoins (studentID, clubID, joinDate) values (23, 24, '2023-04-23');
insert into studentJoins (studentID, clubID, joinDate) values (198, 9, '2025-04-25');
insert into studentJoins (studentID, clubID, joinDate) values (43, 20, '2024-07-23');
insert into studentJoins (studentID, clubID, joinDate) values (147, 2, '2024-07-15');
insert into studentJoins (studentID, clubID, joinDate) values (175, 35, '2025-03-29');
<<<<<<< HEAD
insert into studentJoins (studentID, clubID, joinDate) values (27, 37, '2024-02-22');
=======
insert into studentJoins (studentID, clubID, joinDate) values (27, 19, '2024-02-22');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentJoins (studentID, clubID, joinDate) values (56, 28, '2025-02-08');
insert into studentJoins (studentID, clubID, joinDate) values (51, 16, '2022-09-27');
insert into studentJoins (studentID, clubID, joinDate) values (18, 24, '2022-10-17');
insert into studentJoins (studentID, clubID, joinDate) values (15, 12, '2025-09-08');
insert into studentJoins (studentID, clubID, joinDate) values (120, 31, '2023-07-15');
insert into studentJoins (studentID, clubID, joinDate) values (57, 12, '2025-01-31');
insert into studentJoins (studentID, clubID, joinDate) values (92, 18, '2025-05-31');
insert into studentJoins (studentID, clubID, joinDate) values (49, 29, '2023-05-26');
insert into studentJoins (studentID, clubID, joinDate) values (147, 32, '2025-07-14');
insert into studentJoins (studentID, clubID, joinDate) values (187, 1, '2024-03-11');
insert into studentJoins (studentID, clubID, joinDate) values (32, 26, '2025-10-13');
insert into studentJoins (studentID, clubID, joinDate) values (110, 34, '2024-01-23');
insert into studentJoins (studentID, clubID, joinDate) values (6, 7, '2025-09-06');
insert into studentJoins (studentID, clubID, joinDate) values (72, 15, '2024-07-02');
insert into studentJoins (studentID, clubID, joinDate) values (141, 31, '2025-12-11');
insert into studentJoins (studentID, clubID, joinDate) values (117, 24, '2024-11-27');
insert into studentJoins (studentID, clubID, joinDate) values (178, 23, '2024-12-29');
insert into studentJoins (studentID, clubID, joinDate) values (148, 11, '2023-09-24');

-- 14. studentLeaves
insert into studentLeaves (studentID, clubID, leaveDate) values (174, 25, '2023-01-24');
<<<<<<< HEAD
insert into studentLeaves (studentID, clubID, leaveDate) values (137, 39, '2024-02-08');
=======
insert into studentLeaves (studentID, clubID, leaveDate) values (137, 18, '2024-02-08');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentLeaves (studentID, clubID, leaveDate) values (1, 12, '2025-07-16');
insert into studentLeaves (studentID, clubID, leaveDate) values (159, 23, '2024-07-08');
insert into studentLeaves (studentID, clubID, leaveDate) values (186, 18, '2023-04-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (60, 8, '2025-06-09');
insert into studentLeaves (studentID, clubID, leaveDate) values (63, 11, '2025-01-22');
<<<<<<< HEAD
insert into studentLeaves (studentID, clubID, leaveDate) values (18, 18, '2024-03-10');
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentLeaves (studentID, clubID, leaveDate) values (186, 4, '2023-07-08');
insert into studentLeaves (studentID, clubID, leaveDate) values (117, 25, '2024-11-15');
insert into studentLeaves (studentID, clubID, leaveDate) values (25, 16, '2024-12-20');
insert into studentLeaves (studentID, clubID, leaveDate) values (59, 5, '2024-11-13');
insert into studentLeaves (studentID, clubID, leaveDate) values (116, 31, '2025-07-27');
<<<<<<< HEAD
insert into studentLeaves (studentID, clubID, leaveDate) values (186, 40, '2025-06-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (158, 39, '2025-10-01');
=======
insert into studentLeaves (studentID, clubID, leaveDate) values (186, 17, '2025-06-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (158, 29, '2025-10-01');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentLeaves (studentID, clubID, leaveDate) values (73, 16, '2023-03-06');
insert into studentLeaves (studentID, clubID, leaveDate) values (7, 8, '2023-04-17');
insert into studentLeaves (studentID, clubID, leaveDate) values (171, 14, '2024-02-11');
insert into studentLeaves (studentID, clubID, leaveDate) values (58, 22, '2025-06-06');
<<<<<<< HEAD
insert into studentLeaves (studentID, clubID, leaveDate) values (34, 39, '2024-11-14');
=======
insert into studentLeaves (studentID, clubID, leaveDate) values (34, 17, '2024-11-14');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentLeaves (studentID, clubID, leaveDate) values (173, 20, '2024-09-04');
insert into studentLeaves (studentID, clubID, leaveDate) values (146, 32, '2024-12-21');
insert into studentLeaves (studentID, clubID, leaveDate) values (11, 10, '2025-06-03');
insert into studentLeaves (studentID, clubID, leaveDate) values (44, 1, '2025-12-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (146, 31, '2025-09-06');
insert into studentLeaves (studentID, clubID, leaveDate) values (92, 20, '2024-02-08');
<<<<<<< HEAD
insert into studentLeaves (studentID, clubID, leaveDate) values (191, 37, '2023-09-26');
insert into studentLeaves (studentID, clubID, leaveDate) values (192, 37, '2024-08-03');
=======
insert into studentLeaves (studentID, clubID, leaveDate) values (191, 16, '2023-09-26');
insert into studentLeaves (studentID, clubID, leaveDate) values (192, 15, '2024-08-03');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentLeaves (studentID, clubID, leaveDate) values (20, 19, '2025-09-27');
insert into studentLeaves (studentID, clubID, leaveDate) values (72, 22, '2023-11-19');
insert into studentLeaves (studentID, clubID, leaveDate) values (156, 23, '2024-05-07');
insert into studentLeaves (studentID, clubID, leaveDate) values (86, 10, '2023-11-21');
insert into studentLeaves (studentID, clubID, leaveDate) values (173, 23, '2024-08-14');
insert into studentLeaves (studentID, clubID, leaveDate) values (89, 13, '2023-01-09');
insert into studentLeaves (studentID, clubID, leaveDate) values (107, 13, '2025-08-26');
insert into studentLeaves (studentID, clubID, leaveDate) values (46, 14, '2025-09-05');
insert into studentLeaves (studentID, clubID, leaveDate) values (8, 19, '2023-04-03');
insert into studentLeaves (studentID, clubID, leaveDate) values (17, 29, '2025-11-24');
insert into studentLeaves (studentID, clubID, leaveDate) values (66, 7, '2024-06-26');
insert into studentLeaves (studentID, clubID, leaveDate) values (190, 34, '2024-02-01');
insert into studentLeaves (studentID, clubID, leaveDate) values (112, 14, '2023-03-07');
insert into studentLeaves (studentID, clubID, leaveDate) values (52, 35, '2025-12-13');
insert into studentLeaves (studentID, clubID, leaveDate) values (179, 25, '2024-04-15');
insert into studentLeaves (studentID, clubID, leaveDate) values (144, 6, '2025-11-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (109, 25, '2025-09-09');
insert into studentLeaves (studentID, clubID, leaveDate) values (90, 8, '2024-02-28');
insert into studentLeaves (studentID, clubID, leaveDate) values (146, 22, '2025-11-12');
insert into studentLeaves (studentID, clubID, leaveDate) values (146, 21, '2023-11-24');
insert into studentLeaves (studentID, clubID, leaveDate) values (159, 5, '2023-01-19');
insert into studentLeaves (studentID, clubID, leaveDate) values (67, 21, '2025-01-07');
insert into studentLeaves (studentID, clubID, leaveDate) values (175, 23, '2023-11-29');
<<<<<<< HEAD
insert into studentLeaves (studentID, clubID, leaveDate) values (115, 37, '2024-03-28');
insert into studentLeaves (studentID, clubID, leaveDate) values (70, 21, '2025-09-23');
insert into studentLeaves (studentID, clubID, leaveDate) values (62, 38, '2023-02-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (139, 37, '2024-08-28');
=======
insert into studentLeaves (studentID, clubID, leaveDate) values (115, 29, '2024-03-28');
insert into studentLeaves (studentID, clubID, leaveDate) values (70, 21, '2025-09-23');
insert into studentLeaves (studentID, clubID, leaveDate) values (62, 16, '2023-02-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (139, 10, '2024-08-28');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentLeaves (studentID, clubID, leaveDate) values (143, 11, '2024-02-23');
insert into studentLeaves (studentID, clubID, leaveDate) values (180, 3, '2024-04-24');
insert into studentLeaves (studentID, clubID, leaveDate) values (4, 34, '2023-10-22');
insert into studentLeaves (studentID, clubID, leaveDate) values (112, 15, '2025-10-16');
<<<<<<< HEAD
insert into studentLeaves (studentID, clubID, leaveDate) values (6, 39, '2024-04-05');
=======
insert into studentLeaves (studentID, clubID, leaveDate) values (6, 27, '2024-04-05');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentLeaves (studentID, clubID, leaveDate) values (181, 27, '2025-02-15');
insert into studentLeaves (studentID, clubID, leaveDate) values (135, 14, '2023-05-02');
insert into studentLeaves (studentID, clubID, leaveDate) values (148, 18, '2023-10-29');
insert into studentLeaves (studentID, clubID, leaveDate) values (155, 3, '2025-05-22');
insert into studentLeaves (studentID, clubID, leaveDate) values (168, 15, '2024-02-08');
insert into studentLeaves (studentID, clubID, leaveDate) values (168, 19, '2023-07-06');
insert into studentLeaves (studentID, clubID, leaveDate) values (16, 29, '2024-12-30');
insert into studentLeaves (studentID, clubID, leaveDate) values (184, 11, '2023-06-03');
insert into studentLeaves (studentID, clubID, leaveDate) values (33, 1, '2025-12-20');
insert into studentLeaves (studentID, clubID, leaveDate) values (31, 2, '2025-08-05');
<<<<<<< HEAD
insert into studentLeaves (studentID, clubID, leaveDate) values (135, 40, '2024-10-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (94, 8, '2024-03-19');
insert into studentLeaves (studentID, clubID, leaveDate) values (165, 8, '2023-06-23');
insert into studentLeaves (studentID, clubID, leaveDate) values (103, 37, '2023-06-02');
insert into studentLeaves (studentID, clubID, leaveDate) values (155, 30, '2023-03-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (89, 21, '2023-12-31');
insert into studentLeaves (studentID, clubID, leaveDate) values (146, 37, '2024-12-22');
insert into studentLeaves (studentID, clubID, leaveDate) values (143, 27, '2024-12-14');
insert into studentLeaves (studentID, clubID, leaveDate) values (141, 36, '2023-08-29');
=======
insert into studentLeaves (studentID, clubID, leaveDate) values (135, 29, '2024-10-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (94, 8, '2024-03-19');
insert into studentLeaves (studentID, clubID, leaveDate) values (165, 8, '2023-06-23');
insert into studentLeaves (studentID, clubID, leaveDate) values (155, 30, '2023-03-25');
insert into studentLeaves (studentID, clubID, leaveDate) values (89, 21, '2023-12-31');
insert into studentLeaves (studentID, clubID, leaveDate) values (146, 19, '2024-12-22');
insert into studentLeaves (studentID, clubID, leaveDate) values (143, 27, '2024-12-14');
insert into studentLeaves (studentID, clubID, leaveDate) values (141, 29, '2023-08-29');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentLeaves (studentID, clubID, leaveDate) values (85, 34, '2025-12-23');
insert into studentLeaves (studentID, clubID, leaveDate) values (28, 18, '2024-03-05');
insert into studentLeaves (studentID, clubID, leaveDate) values (104, 17, '2023-04-06');
insert into studentLeaves (studentID, clubID, leaveDate) values (133, 5, '2025-06-06');
insert into studentLeaves (studentID, clubID, leaveDate) values (3, 27, '2025-03-09');
insert into studentLeaves (studentID, clubID, leaveDate) values (187, 10, '2025-08-31');
insert into studentLeaves (studentID, clubID, leaveDate) values (76, 32, '2024-02-05');
insert into studentLeaves (studentID, clubID, leaveDate) values (31, 21, '2024-08-29');
insert into studentLeaves (studentID, clubID, leaveDate) values (161, 4, '2023-04-09');
insert into studentLeaves (studentID, clubID, leaveDate) values (108, 17, '2023-06-14');
insert into studentLeaves (studentID, clubID, leaveDate) values (143, 8, '2025-12-01');
<<<<<<< HEAD
insert into studentLeaves (studentID, clubID, leaveDate) values (82, 36, '2023-10-30');
=======
insert into studentLeaves (studentID, clubID, leaveDate) values (82, 29, '2023-10-30');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentLeaves (studentID, clubID, leaveDate) values (26, 23, '2024-03-31');
insert into studentLeaves (studentID, clubID, leaveDate) values (196, 33, '2023-09-20');
insert into studentLeaves (studentID, clubID, leaveDate) values (152, 5, '2025-01-03');
insert into studentLeaves (studentID, clubID, leaveDate) values (91, 21, '2025-06-08');
insert into studentLeaves (studentID, clubID, leaveDate) values (94, 26, '2023-09-19');
insert into studentLeaves (studentID, clubID, leaveDate) values (102, 27, '2023-04-01');
insert into studentLeaves (studentID, clubID, leaveDate) values (123, 34, '2024-10-21');
insert into studentLeaves (studentID, clubID, leaveDate) values (142, 17, '2024-10-30');
insert into studentLeaves (studentID, clubID, leaveDate) values (94, 29, '2025-11-26');


-- 15. application
<<<<<<< HEAD
=======
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (1, 28, 129, '2024-12-22 15:38:06', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (2, 25, 25, '2025-01-11 15:21:27', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (3, 30, 140, '2025-04-16 20:11:32', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (4, 10, 188, '2025-01-02 13:46:03', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (5, 2, 82, '2025-02-23 16:31:33', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (6, 32, 168, '2025-05-07 23:00:49', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (7, 7, 16, '2025-05-11 01:19:26', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (8, 10, 118, '2025-07-08 00:13:37', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (9, 6, 179, '2025-01-18 14:36:24', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (10, 7, 7, '2025-11-15 13:08:04', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (11, 33, 9, '2025-08-27 03:22:20', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (12, 33, 125, '2025-01-29 07:35:07', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (13, 9, 186, '2024-12-25 02:06:34', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (14, 32, 167, '2025-07-13 11:30:44', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (15, 14, 79, '2025-07-10 09:32:54', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (16, 26, 50, '2024-12-02 20:29:33', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (17, 35, 134, '2025-08-21 05:47:24', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (18, 22, 55, '2025-02-16 01:30:23', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (19, 25, 30, '2025-10-08 10:37:29', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (20, 12, 54, '2025-04-18 17:19:42', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (21, 32, 146, '2025-04-08 20:54:53', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (22, 17, 85, '2025-03-21 10:31:00', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (23, 3, 35, '2025-11-26 17:14:00', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (24, 23, 40, '2025-07-03 19:02:29', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (25, 10, 160, '2025-09-02 18:28:15', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (26, 22, 147, '2025-11-24 18:58:11', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (27, 17, 25, '2025-03-05 22:51:25', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (28, 26, 69, '2024-12-14 05:13:45', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (29, 12, 109, '2025-09-27 04:04:04', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (30, 30, 152, '2025-04-17 19:44:04', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (31, 18, 75, '2025-07-31 05:28:44', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (32, 35, 32, '2025-06-12 22:35:53', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (33, 5, 108, '2025-09-06 05:27:49', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (34, 23, 54, '2025-03-07 00:28:47', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (35, 9, 173, '2024-12-25 03:09:42', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (36, 16, 152, '2025-01-04 21:12:54', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (37, 25, 3, '2025-04-28 08:13:44', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (38, 11, 21, '2025-04-28 02:54:32', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (39, 14, 98, '2025-05-26 19:59:00', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (40, 24, 10, '2025-10-29 08:09:01', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (41, 24, 190, '2025-01-21 02:40:43', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (42, 14, 145, '2025-06-08 10:09:12', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (43, 19, 72, '2025-08-02 20:26:11', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (44, 12, 105, '2025-08-07 00:22:42', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (45, 8, 99, '2025-10-25 01:48:39', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (46, 24, 153, '2025-07-16 22:22:33', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (47, 31, 6, '2025-11-21 10:01:12', 1);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (48, 5, 59, '2025-10-06 02:34:07', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (49, 31, 27, '2025-10-21 10:29:40', 0);
insert into application (applicationID, clubID, studentID, dateSubmitted, status) values (50, 33, 79, '2025-09-28 09:55:22', 0);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72


-- 16. studentEvents
insert into studentEvents (studentID, eventID) values (25, 31);
insert into studentEvents (studentID, eventID) values (15, 2);
insert into studentEvents (studentID, eventID) values (35, 19);
insert into studentEvents (studentID, eventID) values (20, 20);
insert into studentEvents (studentID, eventID) values (35, 10);
insert into studentEvents (studentID, eventID) values (22, 1);
insert into studentEvents (studentID, eventID) values (27, 16);
insert into studentEvents (studentID, eventID) values (29, 12);
insert into studentEvents (studentID, eventID) values (3, 28);
insert into studentEvents (studentID, eventID) values (6, 11);
insert into studentEvents (studentID, eventID) values (6, 4);
insert into studentEvents (studentID, eventID) values (4, 28);
insert into studentEvents (studentID, eventID) values (21, 35);
insert into studentEvents (studentID, eventID) values (33, 1);
insert into studentEvents (studentID, eventID) values (26, 4);
insert into studentEvents (studentID, eventID) values (4, 26);
<<<<<<< HEAD
insert into studentEvents (studentID, eventID) values (28, 30);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentEvents (studentID, eventID) values (7, 32);
insert into studentEvents (studentID, eventID) values (10, 13);
insert into studentEvents (studentID, eventID) values (3, 13);
insert into studentEvents (studentID, eventID) values (2, 27);
insert into studentEvents (studentID, eventID) values (26, 29);
insert into studentEvents (studentID, eventID) values (30, 4);
insert into studentEvents (studentID, eventID) values (1, 30);
insert into studentEvents (studentID, eventID) values (6, 6);
insert into studentEvents (studentID, eventID) values (34, 16);
insert into studentEvents (studentID, eventID) values (12, 11);
insert into studentEvents (studentID, eventID) values (26, 11);
insert into studentEvents (studentID, eventID) values (21, 9);
insert into studentEvents (studentID, eventID) values (33, 21);
insert into studentEvents (studentID, eventID) values (23, 15);
insert into studentEvents (studentID, eventID) values (11, 5);
<<<<<<< HEAD
insert into studentEvents (studentID, eventID) values (28, 30);
insert into studentEvents (studentID, eventID) values (28, 2);
insert into studentEvents (studentID, eventID) values (3, 28);
insert into studentEvents (studentID, eventID) values (25, 34);
insert into studentEvents (studentID, eventID) values (28, 19);
insert into studentEvents (studentID, eventID) values (34, 16);
=======
insert into studentEvents (studentID, eventID) values (28, 2);
insert into studentEvents (studentID, eventID) values (25, 34);
insert into studentEvents (studentID, eventID) values (28, 19);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentEvents (studentID, eventID) values (7, 30);
insert into studentEvents (studentID, eventID) values (34, 32);
insert into studentEvents (studentID, eventID) values (21, 17);
insert into studentEvents (studentID, eventID) values (26, 34);
insert into studentEvents (studentID, eventID) values (23, 7);
insert into studentEvents (studentID, eventID) values (3, 10);
insert into studentEvents (studentID, eventID) values (6, 3);
insert into studentEvents (studentID, eventID) values (22, 20);
insert into studentEvents (studentID, eventID) values (19, 19);
insert into studentEvents (studentID, eventID) values (15, 20);
insert into studentEvents (studentID, eventID) values (19, 21);
insert into studentEvents (studentID, eventID) values (14, 27);
insert into studentEvents (studentID, eventID) values (8, 32);
insert into studentEvents (studentID, eventID) values (16, 11);
insert into studentEvents (studentID, eventID) values (7, 20);
insert into studentEvents (studentID, eventID) values (32, 26);
insert into studentEvents (studentID, eventID) values (7, 4);
<<<<<<< HEAD
insert into studentEvents (studentID, eventID) values (29, 12);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentEvents (studentID, eventID) values (17, 18);
insert into studentEvents (studentID, eventID) values (32, 22);
insert into studentEvents (studentID, eventID) values (25, 29);
insert into studentEvents (studentID, eventID) values (18, 15);
insert into studentEvents (studentID, eventID) values (9, 12);
insert into studentEvents (studentID, eventID) values (30, 7);
insert into studentEvents (studentID, eventID) values (27, 9);
insert into studentEvents (studentID, eventID) values (31, 25);
insert into studentEvents (studentID, eventID) values (22, 15);
insert into studentEvents (studentID, eventID) values (9, 9);
insert into studentEvents (studentID, eventID) values (19, 32);
insert into studentEvents (studentID, eventID) values (1, 25);
insert into studentEvents (studentID, eventID) values (24, 12);
insert into studentEvents (studentID, eventID) values (29, 26);
insert into studentEvents (studentID, eventID) values (23, 25);
insert into studentEvents (studentID, eventID) values (8, 29);
insert into studentEvents (studentID, eventID) values (29, 23);
insert into studentEvents (studentID, eventID) values (6, 31);
insert into studentEvents (studentID, eventID) values (8, 27);
insert into studentEvents (studentID, eventID) values (34, 11);
insert into studentEvents (studentID, eventID) values (19, 12);
insert into studentEvents (studentID, eventID) values (34, 19);
insert into studentEvents (studentID, eventID) values (29, 25);
insert into studentEvents (studentID, eventID) values (5, 12);
insert into studentEvents (studentID, eventID) values (9, 28);
insert into studentEvents (studentID, eventID) values (26, 24);
insert into studentEvents (studentID, eventID) values (6, 13);
insert into studentEvents (studentID, eventID) values (30, 2);
insert into studentEvents (studentID, eventID) values (27, 26);
insert into studentEvents (studentID, eventID) values (32, 9);
<<<<<<< HEAD
insert into studentEvents (studentID, eventID) values (15, 2);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentEvents (studentID, eventID) values (23, 2);
insert into studentEvents (studentID, eventID) values (3, 20);
insert into studentEvents (studentID, eventID) values (33, 3);
insert into studentEvents (studentID, eventID) values (13, 34);
insert into studentEvents (studentID, eventID) values (4, 9);
insert into studentEvents (studentID, eventID) values (13, 25);
insert into studentEvents (studentID, eventID) values (8, 25);
insert into studentEvents (studentID, eventID) values (7, 17);
insert into studentEvents (studentID, eventID) values (14, 15);
insert into studentEvents (studentID, eventID) values (18, 9);
insert into studentEvents (studentID, eventID) values (26, 6);
insert into studentEvents (studentID, eventID) values (2, 29);
<<<<<<< HEAD
insert into studentEvents (studentID, eventID) values (24, 12);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentEvents (studentID, eventID) values (26, 35);
insert into studentEvents (studentID, eventID) values (33, 31);
insert into studentEvents (studentID, eventID) values (26, 3);
insert into studentEvents (studentID, eventID) values (31, 21);
insert into studentEvents (studentID, eventID) values (16, 17);
insert into studentEvents (studentID, eventID) values (28, 11);
insert into studentEvents (studentID, eventID) values (31, 15);
<<<<<<< HEAD
insert into studentEvents (studentID, eventID) values (28, 30);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentEvents (studentID, eventID) values (3, 22);
insert into studentEvents (studentID, eventID) values (26, 32);
insert into studentEvents (studentID, eventID) values (30, 13);
insert into studentEvents (studentID, eventID) values (29, 10);
insert into studentEvents (studentID, eventID) values (3, 17);
insert into studentEvents (studentID, eventID) values (12, 15);
<<<<<<< HEAD
insert into studentEvents (studentID, eventID) values (18, 18);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into studentEvents (studentID, eventID) values (12, 9);
insert into studentEvents (studentID, eventID) values (14, 5);
insert into studentEvents (studentID, eventID) values (30, 27);
insert into studentEvents (studentID, eventID) values (31, 14);
insert into studentEvents (studentID, eventID) values (4, 10);
insert into studentEvents (studentID, eventID) values (12, 30);
insert into studentEvents (studentID, eventID) values (31, 35);
insert into studentEvents (studentID, eventID) values (13, 3);
insert into studentEvents (studentID, eventID) values (21, 1);
insert into studentEvents (studentID, eventID) values (5, 20);
insert into studentEvents (studentID, eventID) values (12, 8);
insert into studentEvents (studentID, eventID) values (16, 24);
insert into studentEvents (studentID, eventID) values (1, 22);
insert into studentEvents (studentID, eventID) values (24, 30);
insert into studentEvents (studentID, eventID) values (12, 35);


-- 17. search
<<<<<<< HEAD
insert into clubEvents (clubID, eventID) values (6, 18);
insert into clubEvents (clubID, eventID) values (31, 23);
insert into clubEvents (clubID, eventID) values (25, 17);
insert into clubEvents (clubID, eventID) values (29, 3);
insert into clubEvents (clubID, eventID) values (4, 7);
insert into clubEvents (clubID, eventID) values (30, 28);
insert into clubEvents (clubID, eventID) values (18, 11);
insert into clubEvents (clubID, eventID) values (15, 3);
insert into clubEvents (clubID, eventID) values (34, 9);
insert into clubEvents (clubID, eventID) values (29, 3);
insert into clubEvents (clubID, eventID) values (16, 17);
insert into clubEvents (clubID, eventID) values (7, 33);
insert into clubEvents (clubID, eventID) values (18, 22);
insert into clubEvents (clubID, eventID) values (27, 30);
insert into clubEvents (clubID, eventID) values (33, 5);
insert into clubEvents (clubID, eventID) values (30, 25);
insert into clubEvents (clubID, eventID) values (19, 3);
insert into clubEvents (clubID, eventID) values (22, 34);
insert into clubEvents (clubID, eventID) values (21, 24);
insert into clubEvents (clubID, eventID) values (22, 35);
insert into clubEvents (clubID, eventID) values (3, 10);
insert into clubEvents (clubID, eventID) values (21, 18);
insert into clubEvents (clubID, eventID) values (11, 24);
insert into clubEvents (clubID, eventID) values (17, 25);
insert into clubEvents (clubID, eventID) values (3, 25);
insert into clubEvents (clubID, eventID) values (27, 2);
insert into clubEvents (clubID, eventID) values (25, 15);
insert into clubEvents (clubID, eventID) values (13, 17);
insert into clubEvents (clubID, eventID) values (33, 12);
insert into clubEvents (clubID, eventID) values (8, 8);
insert into clubEvents (clubID, eventID) values (33, 16);
insert into clubEvents (clubID, eventID) values (29, 5);
insert into clubEvents (clubID, eventID) values (35, 33);
insert into clubEvents (clubID, eventID) values (2, 21);
insert into clubEvents (clubID, eventID) values (22, 3);
insert into clubEvents (clubID, eventID) values (16, 21);
insert into clubEvents (clubID, eventID) values (5, 22);
insert into clubEvents (clubID, eventID) values (11, 18);
insert into clubEvents (clubID, eventID) values (21, 4);
insert into clubEvents (clubID, eventID) values (25, 20);
insert into clubEvents (clubID, eventID) values (29, 13);
insert into clubEvents (clubID, eventID) values (26, 8);
insert into clubEvents (clubID, eventID) values (11, 15);
insert into clubEvents (clubID, eventID) values (16, 31);
insert into clubEvents (clubID, eventID) values (27, 29);
insert into clubEvents (clubID, eventID) values (20, 1);
insert into clubEvents (clubID, eventID) values (15, 24);
insert into clubEvents (clubID, eventID) values (6, 27);
insert into clubEvents (clubID, eventID) values (15, 23);
insert into clubEvents (clubID, eventID) values (1, 17);
insert into clubEvents (clubID, eventID) values (29, 14);
insert into clubEvents (clubID, eventID) values (9, 12);
insert into clubEvents (clubID, eventID) values (9, 11);
insert into clubEvents (clubID, eventID) values (15, 6);
insert into clubEvents (clubID, eventID) values (9, 20);
insert into clubEvents (clubID, eventID) values (21, 34);
insert into clubEvents (clubID, eventID) values (23, 15);
insert into clubEvents (clubID, eventID) values (2, 22);
insert into clubEvents (clubID, eventID) values (35, 3);
insert into clubEvents (clubID, eventID) values (6, 18);
insert into clubEvents (clubID, eventID) values (19, 31);
insert into clubEvents (clubID, eventID) values (7, 7);
insert into clubEvents (clubID, eventID) values (27, 29);
insert into clubEvents (clubID, eventID) values (28, 11);
insert into clubEvents (clubID, eventID) values (24, 23);
insert into clubEvents (clubID, eventID) values (15, 22);
insert into clubEvents (clubID, eventID) values (29, 5);
insert into clubEvents (clubID, eventID) values (22, 32);
insert into clubEvents (clubID, eventID) values (7, 1);
insert into clubEvents (clubID, eventID) values (8, 31);
insert into clubEvents (clubID, eventID) values (34, 29);
insert into clubEvents (clubID, eventID) values (4, 12);
insert into clubEvents (clubID, eventID) values (22, 8);
insert into clubEvents (clubID, eventID) values (20, 34);
insert into clubEvents (clubID, eventID) values (3, 19);
insert into clubEvents (clubID, eventID) values (29, 34);
insert into clubEvents (clubID, eventID) values (33, 2);
insert into clubEvents (clubID, eventID) values (7, 34);
insert into clubEvents (clubID, eventID) values (29, 24);
insert into clubEvents (clubID, eventID) values (22, 30);
insert into clubEvents (clubID, eventID) values (1, 14);
insert into clubEvents (clubID, eventID) values (24, 10);
insert into clubEvents (clubID, eventID) values (30, 1);
insert into clubEvents (clubID, eventID) values (7, 3);
insert into clubEvents (clubID, eventID) values (29, 21);
insert into clubEvents (clubID, eventID) values (25, 7);
insert into clubEvents (clubID, eventID) values (33, 7);
insert into clubEvents (clubID, eventID) values (13, 12);
insert into clubEvents (clubID, eventID) values (27, 10);
insert into clubEvents (clubID, eventID) values (15, 32);
insert into clubEvents (clubID, eventID) values (20, 15);
insert into clubEvents (clubID, eventID) values (3, 31);
insert into clubEvents (clubID, eventID) values (20, 15);
insert into clubEvents (clubID, eventID) values (26, 21);
insert into clubEvents (clubID, eventID) values (35, 29);
insert into clubEvents (clubID, eventID) values (23, 12);
insert into clubEvents (clubID, eventID) values (19, 22);
insert into clubEvents (clubID, eventID) values (27, 31);
insert into clubEvents (clubID, eventID) values (32, 35);
insert into clubEvents (clubID, eventID) values (7, 16);
insert into clubEvents (clubID, eventID) values (13, 4);
insert into clubEvents (clubID, eventID) values (17, 32);
insert into clubEvents (clubID, eventID) values (3, 35);
insert into clubEvents (clubID, eventID) values (9, 9);
insert into clubEvents (clubID, eventID) values (32, 19);
insert into clubEvents (clubID, eventID) values (33, 16);
insert into clubEvents (clubID, eventID) values (33, 4);
insert into clubEvents (clubID, eventID) values (12, 16);
insert into clubEvents (clubID, eventID) values (22, 11);
insert into clubEvents (clubID, eventID) values (15, 12);
insert into clubEvents (clubID, eventID) values (27, 18);
insert into clubEvents (clubID, eventID) values (9, 13);
insert into clubEvents (clubID, eventID) values (23, 24);
insert into clubEvents (clubID, eventID) values (1, 30);
insert into clubEvents (clubID, eventID) values (34, 34);
insert into clubEvents (clubID, eventID) values (21, 14);
insert into clubEvents (clubID, eventID) values (23, 18);
insert into clubEvents (clubID, eventID) values (35, 11);
insert into clubEvents (clubID, eventID) values (2, 2);
insert into clubEvents (clubID, eventID) values (2, 27);
insert into clubEvents (clubID, eventID) values (23, 27);
insert into clubEvents (clubID, eventID) values (18, 5);
insert into clubEvents (clubID, eventID) values (22, 5);
insert into clubEvents (clubID, eventID) values (4, 22);
insert into clubEvents (clubID, eventID) values (34, 25);
insert into clubEvents (clubID, eventID) values (32, 11);
insert into clubEvents (clubID, eventID) values (15, 4);
insert into clubEvents (clubID, eventID) values (20, 25);
insert into clubEvents (clubID, eventID) values (31, 5);
insert into clubEvents (clubID, eventID) values (13, 18);

=======
insert into search (searchID, studentID, name, dateTime) values (1, 77, 'scholarship', '2025-02-09 19:40:38');
insert into search (searchID, studentID, name, dateTime) values (2, 163, 'academic journal', '2025-10-08 21:40:10');
insert into search (searchID, studentID, name, dateTime) values (3, 45, 'scholarship', '2025-10-31 19:16:42');
insert into search (searchID, studentID, name, dateTime) values (4, 132, 'academic journal', '2025-11-03 22:34:44');
insert into search (searchID, studentID, name, dateTime) values (5, 55, 'academic conference', '2025-10-18 03:40:43');
insert into search (searchID, studentID, name, dateTime) values (6, 13, 'research', '2025-06-06 14:09:11');
insert into search (searchID, studentID, name, dateTime) values (7, 79, 'academic journal', '2025-09-08 22:08:05');
insert into search (searchID, studentID, name, dateTime) values (8, 5, 'research', '2025-11-02 02:30:29');
insert into search (searchID, studentID, name, dateTime) values (9, 68, 'study group', '2025-01-14 04:25:04');
insert into search (searchID, studentID, name, dateTime) values (10, 144, 'research', '2025-07-22 10:06:32');
insert into search (searchID, studentID, name, dateTime) values (11, 165, 'study group', '2025-10-07 06:34:11');
insert into search (searchID, studentID, name, dateTime) values (12, 63, 'academic journal', '2025-04-16 22:28:44');
insert into search (searchID, studentID, name, dateTime) values (13, 33, 'research', '2025-09-07 19:01:55');
insert into search (searchID, studentID, name, dateTime) values (14, 183, 'academic conference', '2025-11-18 17:14:32');
insert into search (searchID, studentID, name, dateTime) values (15, 195, 'academic journal', '2025-11-22 06:27:49');
insert into search (searchID, studentID, name, dateTime) values (16, 67, 'research', '2025-06-26 14:59:14');
insert into search (searchID, studentID, name, dateTime) values (17, 86, 'scholarship', '2025-08-07 09:05:28');
insert into search (searchID, studentID, name, dateTime) values (18, 131, 'study group', '2025-05-30 23:34:51');
insert into search (searchID, studentID, name, dateTime) values (19, 53, 'academic journal', '2025-06-23 10:30:01');
insert into search (searchID, studentID, name, dateTime) values (20, 123, 'academic journal', '2025-04-26 10:20:25');
insert into search (searchID, studentID, name, dateTime) values (21, 86, 'academic journal', '2024-12-18 04:01:55');
insert into search (searchID, studentID, name, dateTime) values (22, 191, 'academic journal', '2025-04-20 09:54:31');
insert into search (searchID, studentID, name, dateTime) values (23, 4, 'scholarship', '2025-05-16 10:20:24');
insert into search (searchID, studentID, name, dateTime) values (24, 83, 'scholarship', '2025-08-25 12:56:55');
insert into search (searchID, studentID, name, dateTime) values (25, 169, 'scholarship', '2025-01-10 00:19:38');
insert into search (searchID, studentID, name, dateTime) values (26, 34, 'academic conference', '2025-07-17 03:26:08');
insert into search (searchID, studentID, name, dateTime) values (27, 11, 'research', '2025-03-15 17:26:02');
insert into search (searchID, studentID, name, dateTime) values (28, 102, 'academic conference', '2025-07-13 02:07:39');
insert into search (searchID, studentID, name, dateTime) values (29, 162, 'academic journal', '2025-04-21 23:31:37');
insert into search (searchID, studentID, name, dateTime) values (30, 127, 'academic journal', '2025-10-12 05:09:32');
insert into search (searchID, studentID, name, dateTime) values (31, 70, 'academic journal', '2025-01-25 19:17:09');
insert into search (searchID, studentID, name, dateTime) values (32, 146, 'study group', '2025-11-10 03:39:26');
insert into search (searchID, studentID, name, dateTime) values (33, 25, 'research', '2025-04-09 00:43:29');
insert into search (searchID, studentID, name, dateTime) values (34, 130, 'research', '2025-01-13 17:18:54');
insert into search (searchID, studentID, name, dateTime) values (35, 174, 'academic conference', '2025-07-02 22:48:52');
insert into search (searchID, studentID, name, dateTime) values (36, 120, 'academic journal', '2025-01-23 13:16:51');
insert into search (searchID, studentID, name, dateTime) values (37, 182, 'academic conference', '2025-07-19 14:55:50');
insert into search (searchID, studentID, name, dateTime) values (38, 123, 'scholarship', '2024-12-06 19:12:44');
insert into search (searchID, studentID, name, dateTime) values (39, 42, 'study group', '2025-02-10 02:33:49');
insert into search (searchID, studentID, name, dateTime) values (40, 44, 'scholarship', '2025-05-30 18:41:24');
insert into search (searchID, studentID, name, dateTime) values (41, 48, 'academic journal', '2025-03-31 22:27:14');
insert into search (searchID, studentID, name, dateTime) values (42, 145, 'research', '2025-06-11 11:06:44');
insert into search (searchID, studentID, name, dateTime) values (43, 68, 'scholarship', '2025-08-14 15:59:57');
insert into search (searchID, studentID, name, dateTime) values (44, 136, 'study group', '2025-02-10 22:07:01');
insert into search (searchID, studentID, name, dateTime) values (45, 3, 'scholarship', '2025-01-08 00:56:32');
insert into search (searchID, studentID, name, dateTime) values (46, 94, 'academic conference', '2025-01-22 12:45:03');
insert into search (searchID, studentID, name, dateTime) values (47, 87, 'scholarship', '2025-03-11 00:36:57');
insert into search (searchID, studentID, name, dateTime) values (48, 61, 'research', '2025-09-28 17:52:44');
insert into search (searchID, studentID, name, dateTime) values (49, 57, 'scholarship', '2025-03-28 12:18:35');
insert into search (searchID, studentID, name, dateTime) values (50, 155, 'study group', '2025-04-18 15:50:06');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72

-- 18. adminContact
insert into adminContact (adminID, eboardID) values (21, 12);
insert into adminContact (adminID, eboardID) values (19, 29);
insert into adminContact (adminID, eboardID) values (19, 21);
insert into adminContact (adminID, eboardID) values (11, 12);
insert into adminContact (adminID, eboardID) values (26, 22);
insert into adminContact (adminID, eboardID) values (18, 6);
insert into adminContact (adminID, eboardID) values (18, 25);
insert into adminContact (adminID, eboardID) values (22, 17);
<<<<<<< HEAD
insert into adminContact (adminID, eboardID) values (18, 6);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminContact (adminID, eboardID) values (29, 21);
insert into adminContact (adminID, eboardID) values (26, 1);
insert into adminContact (adminID, eboardID) values (21, 4);
insert into adminContact (adminID, eboardID) values (34, 34);
insert into adminContact (adminID, eboardID) values (22, 4);
insert into adminContact (adminID, eboardID) values (10, 28);
insert into adminContact (adminID, eboardID) values (9, 23);
insert into adminContact (adminID, eboardID) values (17, 22);
insert into adminContact (adminID, eboardID) values (3, 11);
insert into adminContact (adminID, eboardID) values (27, 17);
insert into adminContact (adminID, eboardID) values (26, 31);
insert into adminContact (adminID, eboardID) values (6, 13);
insert into adminContact (adminID, eboardID) values (19, 20);
insert into adminContact (adminID, eboardID) values (29, 33);
insert into adminContact (adminID, eboardID) values (5, 17);
insert into adminContact (adminID, eboardID) values (8, 24);
insert into adminContact (adminID, eboardID) values (34, 24);
insert into adminContact (adminID, eboardID) values (35, 3);
insert into adminContact (adminID, eboardID) values (15, 27);
insert into adminContact (adminID, eboardID) values (8, 19);
insert into adminContact (adminID, eboardID) values (16, 19);
insert into adminContact (adminID, eboardID) values (35, 6);
insert into adminContact (adminID, eboardID) values (31, 29);
insert into adminContact (adminID, eboardID) values (15, 24);
insert into adminContact (adminID, eboardID) values (14, 23);
insert into adminContact (adminID, eboardID) values (35, 34);
insert into adminContact (adminID, eboardID) values (14, 26);
insert into adminContact (adminID, eboardID) values (2, 19);
insert into adminContact (adminID, eboardID) values (32, 25);
insert into adminContact (adminID, eboardID) values (18, 23);
insert into adminContact (adminID, eboardID) values (1, 2);
insert into adminContact (adminID, eboardID) values (29, 7);
insert into adminContact (adminID, eboardID) values (12, 2);
insert into adminContact (adminID, eboardID) values (15, 21);
insert into adminContact (adminID, eboardID) values (18, 24);
insert into adminContact (adminID, eboardID) values (24, 9);
insert into adminContact (adminID, eboardID) values (35, 2);
insert into adminContact (adminID, eboardID) values (1, 31);
insert into adminContact (adminID, eboardID) values (18, 30);
insert into adminContact (adminID, eboardID) values (31, 33);
insert into adminContact (adminID, eboardID) values (7, 28);
insert into adminContact (adminID, eboardID) values (29, 30);
insert into adminContact (adminID, eboardID) values (12, 6);
insert into adminContact (adminID, eboardID) values (4, 24);
insert into adminContact (adminID, eboardID) values (23, 10);
insert into adminContact (adminID, eboardID) values (34, 19);
insert into adminContact (adminID, eboardID) values (32, 7);
<<<<<<< HEAD
insert into adminContact (adminID, eboardID) values (24, 18);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminContact (adminID, eboardID) values (32, 28);
insert into adminContact (adminID, eboardID) values (21, 35);
insert into adminContact (adminID, eboardID) values (17, 26);
insert into adminContact (adminID, eboardID) values (25, 30);
insert into adminContact (adminID, eboardID) values (23, 8);
insert into adminContact (adminID, eboardID) values (2, 16);
insert into adminContact (adminID, eboardID) values (27, 11);
insert into adminContact (adminID, eboardID) values (30, 32);
<<<<<<< HEAD
insert into adminContact (adminID, eboardID) values (1, 18);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminContact (adminID, eboardID) values (16, 34);
insert into adminContact (adminID, eboardID) values (2, 32);
insert into adminContact (adminID, eboardID) values (23, 17);
insert into adminContact (adminID, eboardID) values (13, 6);
<<<<<<< HEAD
insert into adminContact (adminID, eboardID) values (23, 10);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminContact (adminID, eboardID) values (3, 3);
insert into adminContact (adminID, eboardID) values (6, 28);
insert into adminContact (adminID, eboardID) values (21, 3);
insert into adminContact (adminID, eboardID) values (4, 30);
insert into adminContact (adminID, eboardID) values (27, 15);
<<<<<<< HEAD
insert into adminContact (adminID, eboardID) values (32, 18);
insert into adminContact (adminID, eboardID) values (21, 25);
insert into adminContact (adminID, eboardID) values (15, 4);
insert into adminContact (adminID, eboardID) values (14, 26);
=======
insert into adminContact (adminID, eboardID) values (21, 25);
insert into adminContact (adminID, eboardID) values (15, 4);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminContact (adminID, eboardID) values (30, 23);
insert into adminContact (adminID, eboardID) values (21, 1);
insert into adminContact (adminID, eboardID) values (5, 16);
insert into adminContact (adminID, eboardID) values (25, 16);
insert into adminContact (adminID, eboardID) values (31, 21);
insert into adminContact (adminID, eboardID) values (32, 10);
insert into adminContact (adminID, eboardID) values (34, 15);
<<<<<<< HEAD
insert into adminContact (adminID, eboardID) values (16, 19);
insert into adminContact (adminID, eboardID) values (13, 31);
insert into adminContact (adminID, eboardID) values (3, 3);
=======
insert into adminContact (adminID, eboardID) values (13, 31);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminContact (adminID, eboardID) values (27, 23);
insert into adminContact (adminID, eboardID) values (24, 20);
insert into adminContact (adminID, eboardID) values (14, 2);
insert into adminContact (adminID, eboardID) values (29, 17);
insert into adminContact (adminID, eboardID) values (7, 7);
insert into adminContact (adminID, eboardID) values (26, 26);
<<<<<<< HEAD
insert into adminContact (adminID, eboardID) values (7, 28);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminContact (adminID, eboardID) values (12, 35);
insert into adminContact (adminID, eboardID) values (17, 21);
insert into adminContact (adminID, eboardID) values (29, 5);
insert into adminContact (adminID, eboardID) values (28, 34);
insert into adminContact (adminID, eboardID) values (11, 11);
insert into adminContact (adminID, eboardID) values (8, 32);
insert into adminContact (adminID, eboardID) values (21, 20);
insert into adminContact (adminID, eboardID) values (13, 21);
insert into adminContact (adminID, eboardID) values (27, 8);
insert into adminContact (adminID, eboardID) values (30, 9);
insert into adminContact (adminID, eboardID) values (30, 1);
<<<<<<< HEAD
insert into adminContact (adminID, eboardID) values (25, 18);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminContact (adminID, eboardID) values (28, 31);
insert into adminContact (adminID, eboardID) values (6, 1);
insert into adminContact (adminID, eboardID) values (13, 13);
insert into adminContact (adminID, eboardID) values (16, 26);
insert into adminContact (adminID, eboardID) values (17, 29);
insert into adminContact (adminID, eboardID) values (24, 15);
insert into adminContact (adminID, eboardID) values (24, 3);
insert into adminContact (adminID, eboardID) values (33, 24);
insert into adminContact (adminID, eboardID) values (30, 13);
<<<<<<< HEAD
insert into adminContact (adminID, eboardID) values (29, 5);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminContact (adminID, eboardID) values (13, 10);
insert into adminContact (adminID, eboardID) values (15, 19);
insert into adminContact (adminID, eboardID) values (29, 31);
insert into adminContact (adminID, eboardID) values (33, 7);
insert into adminContact (adminID, eboardID) values (13, 30);
insert into adminContact (adminID, eboardID) values (2, 26);
<<<<<<< HEAD
insert into adminContact (adminID, eboardID) values (30, 9);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminContact (adminID, eboardID) values (25, 33);
insert into adminContact (adminID, eboardID) values (4, 14);
insert into adminContact (adminID, eboardID) values (18, 2);
insert into adminContact (adminID, eboardID) values (11, 24);


-- 19. error
<<<<<<< HEAD
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 4, '504 Gateway Timeout', 'Restarted the system', '2025-09-28 19:29:46', '2025-12-01 12:20:26', 93);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (6, 5, '429 Too Many Requests', 'Cleared cache and cookies', '2025-02-07 18:55:30', '2025-08-02 07:45:38', 83);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (9, 1, '502 Bad Gateway', 'Performed a system restore', '2025-12-30 09:05:57', '2025-01-31 22:13:30', 10);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (4, 2, '403 Forbidden', 'Contacted customer support', '2025-02-02 19:56:48', '2025-02-10 18:38:19', 93);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 2, '429 Too Many Requests', 'Reviewed error logs', '2025-08-27 01:56:56', '2025-09-24 20:07:45', 67);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 6, '401 Unauthorized', 'Checked the network connection', '2025-01-16 19:54:19', '2025-03-08 04:06:07', 37);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (10, 3, '429 Too Many Requests', 'Reinstalled the application', '2025-11-06 20:36:20', '2025-11-30 22:25:57', 78);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (7, 10, '404 Not Found', 'Checked the network connection', '2025-04-25 07:37:13', '2025-06-17 04:06:29', 29);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 1, '401 Unauthorized', 'Reinstalled the application', '2025-11-29 03:41:11', '2025-11-24 02:03:01', 65);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (8, 7, '429 Too Many Requests', 'Reinstalled the application', '2025-12-28 04:39:21', '2025-06-29 04:37:51', 16);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (4, 6, '404 Not Found', 'Restarted the system', '2024-12-31 19:33:29', '2025-05-10 16:43:12', 89);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 5, '408 Request Timeout', 'Reviewed error logs', '2025-11-13 08:38:19', '2025-11-08 18:43:34', 40);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (7, 5, '401 Unauthorized', 'Restarted the system', '2025-09-22 17:28:08', '2025-08-29 08:59:17', 39);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 9, '429 Too Many Requests', 'Cleared cache and cookies', '2025-01-10 12:29:36', '2025-11-10 20:17:29', 75);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (7, 1, '408 Request Timeout', 'Updated the software', '2025-07-08 01:01:46', '2025-08-17 12:46:40', 51);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (4, 9, '403 Forbidden', 'Reviewed error logs', '2025-01-22 21:24:44', '2025-01-22 04:33:50', 27);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (6, 10, '404 Not Found', 'Cleared cache and cookies', '2025-01-19 21:30:09', '2025-03-09 19:11:12', 29);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (7, 7, '500 Internal Server Error', 'Performed a system restore', '2025-12-01 06:40:50', '2025-11-03 09:55:39', 1);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (6, 5, '408 Request Timeout', 'Reinstalled the application', '2025-11-29 10:15:42', '2025-11-02 10:10:26', 64);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 7, '429 Too Many Requests', 'Reinstalled the application', '2025-09-27 19:11:52', '2025-03-31 08:12:11', 18);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (3, 8, '401 Unauthorized', 'Restarted the system', '2025-08-17 03:20:03', '2025-11-02 02:44:25', 76);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (1, 7, '404 Not Found', 'Reinstalled the application', '2025-06-11 23:02:32', '2025-11-26 18:46:37', 59);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (9, 5, '400 Bad Request', 'Contacted customer support', '2025-04-06 05:40:04', '2025-11-20 04:25:49', 45);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (1, 8, '429 Too Many Requests', 'Restarted the system', '2025-01-18 02:59:35', '2025-08-20 01:43:41', 41);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (4, 6, '404 Not Found', 'Contacted customer support', '2025-01-08 20:23:41', '2025-02-05 01:57:46', 91);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (3, 8, '400 Bad Request', 'Restarted the system', '2025-12-12 00:11:21', '2025-06-15 19:42:56', 12);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (6, 4, '503 Service Unavailable', 'Performed a system restore', '2025-06-17 12:11:02', '2025-11-08 06:24:09', 27);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (6, 8, '401 Unauthorized', 'Reinstalled the application', '2025-06-21 11:19:56', '2025-08-30 17:42:42', 17);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 10, '404 Not Found', 'Restarted the system', '2025-11-16 21:26:29', '2025-09-25 20:30:28', 91);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (10, 4, '400 Bad Request', 'Rebooted the device', '2025-08-09 01:20:48', '2025-03-13 11:11:16', 60);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (6, 7, '504 Gateway Timeout', 'Reviewed error logs', '2025-06-04 11:40:20', '2025-09-30 09:39:56', 7);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 4, '500 Internal Server Error', 'Rebooted the device', '2025-06-25 09:18:35', '2025-09-26 11:58:15', 92);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (6, 9, '503 Service Unavailable', 'Cleared cache and cookies', '2025-11-29 19:51:03', '2025-03-29 17:43:43', 95);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 2, '401 Unauthorized', 'Updated the software', '2025-01-01 22:11:28', '2025-12-21 05:59:42', 16);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (8, 9, '504 Gateway Timeout', 'Rebooted the device', '2025-01-23 19:05:37', '2025-12-10 03:02:23', 65);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (4, 1, '408 Request Timeout', 'Contacted customer support', '2025-01-30 20:00:58', '2025-05-06 05:24:09', 17);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 10, '500 Internal Server Error', 'Contacted customer support', '2025-07-10 08:44:38', '2025-04-29 00:59:36', 81);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (3, 10, '403 Forbidden', 'Restarted the system', '2025-03-02 03:14:50', '2025-03-08 10:58:28', 53);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (10, 4, '500 Internal Server Error', 'Rebooted the device', '2025-09-25 14:31:22', '2025-01-12 00:31:23', 79);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 2, '403 Forbidden', 'Checked the network connection', '2025-05-08 20:11:58', '2025-07-08 03:31:15', 98);
=======
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (1, 1, 'logic error', 'Restart the system', '2024-12-10 20:12:41', '2024-12-20 04:19:38', 1);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (4, 8, 'network error', 'Check network connection', '2025-03-18 08:34:57', '2025-02-15 03:24:30', 2);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (1, 10, 'runtime error', 'Contact support', '2025-11-24 06:33:39', '2025-06-19 05:53:19', 3);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 2, 'network error', 'Clear cache', '2025-10-11 05:05:06', '2025-01-29 13:11:06', 4);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 9, 'logic error', 'Update software', '2024-12-06 12:45:47', '2025-10-30 13:37:12', 5);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 2, 'database error', 'Check network connection', '2025-11-11 08:18:39', '2025-01-19 22:29:52', 6);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (10, 1, 'logic error', 'Update software', '2025-09-29 17:32:09', '2025-04-02 06:16:16', 7);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 5, 'network error', 'Update software', '2025-10-28 05:25:25', '2025-03-04 07:01:04', 8);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (7, 2, 'network error', 'Contact support', '2025-11-03 06:52:45', '2025-10-14 22:45:59', 9);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (7, 8, 'logic error', 'Clear cache', '2025-03-17 22:51:22', '2025-11-11 02:42:37', 10);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (3, 10, 'database error', 'Contact support', '2025-11-30 00:12:42', '2025-07-10 09:33:58', 11);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 5, 'syntax error', 'Update software', '2025-02-15 19:09:55', '2025-02-07 03:54:10', 12);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (4, 10, 'database error', 'Contact support', '2025-08-24 08:53:06', '2025-03-16 16:10:00', 13);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (1, 10, 'network error', 'Restart the system', '2025-07-04 12:46:27', '2025-02-25 21:22:47', 14);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 3, 'network error', 'Check network connection', '2025-01-23 06:11:06', '2025-04-04 05:14:45', 15);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 8, 'network error', 'Check network connection', '2025-04-15 23:04:08', '2024-12-13 05:46:47', 16);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (1, 5, 'syntax error', 'Update software', '2025-10-05 00:17:52', '2025-11-02 15:15:52', 17);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (6, 6, 'database error', 'Update software', '2025-03-13 06:47:20', '2024-12-26 03:51:05', 18);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 5, 'syntax error', 'Restart the system', '2025-06-18 08:27:46', '2025-04-04 03:07:09', 19);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (9, 8, 'runtime error', 'Update software', '2025-08-19 19:29:41', '2025-06-11 00:57:04', 20);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (3, 5, 'runtime error', 'Restart the system', '2025-01-31 11:54:34', '2025-08-10 14:25:59', 21);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 3, 'syntax error', 'Update software', '2025-05-27 12:31:46', '2025-01-18 06:07:18', 22);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (4, 7, 'database error', 'Contact support', '2025-10-22 02:11:52', '2025-10-18 04:49:43', 23);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (6, 1, 'logic error', 'Update software', '2025-09-01 20:30:56', '2025-08-20 09:03:43', 24);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (6, 9, 'network error', 'Restart the system', '2025-03-12 17:33:01', '2025-10-16 00:37:00', 25);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (7, 4, 'network error', 'Restart the system', '2025-05-26 13:30:26', '2025-05-30 10:50:50', 26);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 5, 'network error', 'Restart the system', '2025-08-01 13:33:49', '2025-10-23 10:08:31', 27);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (1, 2, 'database error', 'Check network connection', '2025-08-03 16:30:22', '2025-07-05 19:43:27', 28);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (3, 7, 'network error', 'Clear cache', '2024-12-17 19:18:10', '2025-11-22 16:43:33', 29);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 2, 'network error', 'Check network connection', '2025-11-28 07:28:30', '2025-06-13 03:24:39', 30);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (9, 6, 'logic error', 'Restart the system', '2025-04-13 03:23:51', '2024-12-08 21:49:31', 31);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 1, 'syntax error', 'Update software', '2025-03-17 04:41:53', '2025-01-13 15:02:33', 32);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 5, 'database error', 'Restart the system', '2025-03-13 03:07:30', '2024-12-29 00:06:09', 33);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (7, 5, 'network error', 'Check network connection', '2025-10-21 22:58:24', '2025-04-13 08:07:24', 34);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (10, 4, 'logic error', 'Clear cache', '2025-07-25 01:12:18', '2025-12-01 01:10:43', 35);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (5, 10, 'database error', 'Update software', '2025-02-16 07:48:36', '2025-07-05 19:10:52', 36);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (8, 3, 'logic error', 'Clear cache', '2025-02-12 10:36:30', '2025-11-28 00:02:48', 37);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (1, 6, 'logic error', 'Restart the system', '2025-05-01 18:05:44', '2025-11-13 15:17:37', 38);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (9, 2, 'runtime error', 'Clear cache', '2025-03-13 11:58:24', '2025-07-22 06:39:07', 39);
insert into error (systemID, updateID, errorType, errorSolution, timeReported, timeSolved, errorID) values (2, 4, 'logic error', 'Restart the system', '2025-11-10 20:35:29', '2025-07-19 18:58:57', 40);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72


-- 20. adminPermissions

insert into adminPermissions (adminID, permission) values (14, 'write access');
insert into adminPermissions (adminID, permission) values (9, 'custom access');
insert into adminPermissions (adminID, permission) values (19, 'restricted access');
insert into adminPermissions (adminID, permission) values (7, 'custom access');
insert into adminPermissions (adminID, permission) values (16, 'restricted access');
insert into adminPermissions (adminID, permission) values (11, 'restricted access');
insert into adminPermissions (adminID, permission) values (1, 'write access');
<<<<<<< HEAD
insert into adminPermissions (adminID, permission) values (19, 'restricted access');
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminPermissions (adminID, permission) values (5, 'limited access');
insert into adminPermissions (adminID, permission) values (7, 'guest access');
insert into adminPermissions (adminID, permission) values (3, 'view-only access');
insert into adminPermissions (adminID, permission) values (20, 'view-only access');
insert into adminPermissions (adminID, permission) values (10, 'view-only access');
insert into adminPermissions (adminID, permission) values (8, 'full access');
insert into adminPermissions (adminID, permission) values (2, 'full access');
insert into adminPermissions (adminID, permission) values (11, 'limited access');
insert into adminPermissions (adminID, permission) values (1, 'guest access');
insert into adminPermissions (adminID, permission) values (10, 'admin access');
insert into adminPermissions (adminID, permission) values (1, 'admin access');
insert into adminPermissions (adminID, permission) values (17, 'read-only access');
insert into adminPermissions (adminID, permission) values (18, 'read-only access');
insert into adminPermissions (adminID, permission) values (14, 'full access');
insert into adminPermissions (adminID, permission) values (1, 'custom access');
insert into adminPermissions (adminID, permission) values (16, 'superuser access');
insert into adminPermissions (adminID, permission) values (5, 'read-only access');
insert into adminPermissions (adminID, permission) values (5, 'guest access');
insert into adminPermissions (adminID, permission) values (12, 'guest access');
insert into adminPermissions (adminID, permission) values (9, 'admin access');
<<<<<<< HEAD
insert into adminPermissions (adminID, permission) values (1, 'write access');
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminPermissions (adminID, permission) values (11, 'write access');
insert into adminPermissions (adminID, permission) values (8, 'view-only access');
insert into adminPermissions (adminID, permission) values (11, 'full access');
insert into adminPermissions (adminID, permission) values (1, 'limited access');
insert into adminPermissions (adminID, permission) values (2, 'custom access');
insert into adminPermissions (adminID, permission) values (9, 'limited access');
<<<<<<< HEAD
insert into adminPermissions (adminID, permission) values (11, 'write access');
=======
insert into adminPermissions (adminID, permission) values (3, 'write access');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminPermissions (adminID, permission) values (15, 'limited access');
insert into adminPermissions (adminID, permission) values (16, 'admin access');
insert into adminPermissions (adminID, permission) values (6, 'full access');
insert into adminPermissions (adminID, permission) values (9, 'write access');
insert into adminPermissions (adminID, permission) values (16, 'limited access');
<<<<<<< HEAD
insert into adminPermissions (adminID, permission) values (17, 'read-only access');
insert into adminPermissions (adminID, permission) values (10, 'custom access');
insert into adminPermissions (adminID, permission) values (2, 'full access');
insert into adminPermissions (adminID, permission) values (7, 'superuser access');
insert into adminPermissions (adminID, permission) values (16, 'custom access');
insert into adminPermissions (adminID, permission) values (14, 'full access');
insert into adminPermissions (adminID, permission) values (16, 'custom access');
=======
insert into adminPermissions (adminID, permission) values (7, 'read-only access');
insert into adminPermissions (adminID, permission) values (10, 'custom access');
insert into adminPermissions (adminID, permission) values (20, 'full access');
insert into adminPermissions (adminID, permission) values (7, 'superuser access');
insert into adminPermissions (adminID, permission) values (16, 'custom access');
insert into adminPermissions (adminID, permission) values (1, 'full access');
insert into adminPermissions (adminID, permission) values (6, 'custom access');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into adminPermissions (adminID, permission) values (15, 'superuser access');
insert into adminPermissions (adminID, permission) values (6, 'superuser access');


-- 21. eboardPermissions
insert into eboardPermissions (eboardMemberID, permission) values (25, 'Post Announcements');
insert into eboardPermissions (eboardMemberID, permission) values (55, 'Reject Applications');
insert into eboardPermissions (eboardMemberID, permission) values (41, 'Approve Applications');
insert into eboardPermissions (eboardMemberID, permission) values (31, 'Update Member Tiers');
insert into eboardPermissions (eboardMemberID, permission) values (22, 'Create Events');
insert into eboardPermissions (eboardMemberID, permission) values (62, 'View Analytics');
insert into eboardPermissions (eboardMemberID, permission) values (26, 'Send Emails');
insert into eboardPermissions (eboardMemberID, permission) values (45, 'Edit Event Details');
insert into eboardPermissions (eboardMemberID, permission) values (60, 'Manage Permissions');
insert into eboardPermissions (eboardMemberID, permission) values (24, 'Manage Members');
insert into eboardPermissions (eboardMemberID, permission) values (8, 'View Analytics');
insert into eboardPermissions (eboardMemberID, permission) values (32, 'Archive Events');
insert into eboardPermissions (eboardMemberID, permission) values (8, 'Create Events');
insert into eboardPermissions (eboardMemberID, permission) values (48, 'Delete Events');
insert into eboardPermissions (eboardMemberID, permission) values (11, 'Manage Permissions');
insert into eboardPermissions (eboardMemberID, permission) values (46, 'Reject Applications');
insert into eboardPermissions (eboardMemberID, permission) values (40, 'Manage Members');
insert into eboardPermissions (eboardMemberID, permission) values (44, 'View Analytics');
insert into eboardPermissions (eboardMemberID, permission) values (34, 'Delete Events');
insert into eboardPermissions (eboardMemberID, permission) values (28, 'Update Member Tiers');
insert into eboardPermissions (eboardMemberID, permission) values (35, 'Edit Club Info');
insert into eboardPermissions (eboardMemberID, permission) values (30, 'Archive Events');
insert into eboardPermissions (eboardMemberID, permission) values (31, 'View Analytics');
insert into eboardPermissions (eboardMemberID, permission) values (39, 'Post Announcements');
insert into eboardPermissions (eboardMemberID, permission) values (56, 'Manage Budget');
insert into eboardPermissions (eboardMemberID, permission) values (33, 'Send Emails');
insert into eboardPermissions (eboardMemberID, permission) values (33, 'Create Events');
insert into eboardPermissions (eboardMemberID, permission) values (59, 'Create Events');
insert into eboardPermissions (eboardMemberID, permission) values (35, 'Reject Applications');
insert into eboardPermissions (eboardMemberID, permission) values (17, 'Manage Permissions');
insert into eboardPermissions (eboardMemberID, permission) values (34, 'Post Announcements');
insert into eboardPermissions (eboardMemberID, permission) values (60, 'Reject Applications');
insert into eboardPermissions (eboardMemberID, permission) values (58, 'Post Announcements');
insert into eboardPermissions (eboardMemberID, permission) values (46, 'Manage Budget');
insert into eboardPermissions (eboardMemberID, permission) values (14, 'Create Events');
insert into eboardPermissions (eboardMemberID, permission) values (9, 'Manage Budget');
insert into eboardPermissions (eboardMemberID, permission) values (35, 'Post Announcements');
insert into eboardPermissions (eboardMemberID, permission) values (17, 'Archive Events');
insert into eboardPermissions (eboardMemberID, permission) values (22, 'Approve Applications');
insert into eboardPermissions (eboardMemberID, permission) values (3, 'Archive Events');
insert into eboardPermissions (eboardMemberID, permission) values (17, 'Send Emails');
insert into eboardPermissions (eboardMemberID, permission) values (13, 'Update Member Tiers');
insert into eboardPermissions (eboardMemberID, permission) values (47, 'Send Emails');
insert into eboardPermissions (eboardMemberID, permission) values (28, 'Edit Club Info');
insert into eboardPermissions (eboardMemberID, permission) values (47, 'Manage Budget');
insert into eboardPermissions (eboardMemberID, permission) values (6, 'Approve Applications');
insert into eboardPermissions (eboardMemberID, permission) values (38, 'View Analytics');
insert into eboardPermissions (eboardMemberID, permission) values (58, 'Send Emails');
insert into eboardPermissions (eboardMemberID, permission) values (32, 'Edit Event Details');
insert into eboardPermissions (eboardMemberID, permission) values (50, 'Send Emails');
insert into eboardPermissions (eboardMemberID, permission) values (7, 'Edit Club Info');
insert into eboardPermissions (eboardMemberID, permission) values (20, 'Send Emails');
insert into eboardPermissions (eboardMemberID, permission) values (17, 'Approve Applications');
insert into eboardPermissions (eboardMemberID, permission) values (31, 'Edit Event Details');
insert into eboardPermissions (eboardMemberID, permission) values (52, 'View Analytics');
insert into eboardPermissions (eboardMemberID, permission) values (44, 'Create Events');
insert into eboardPermissions (eboardMemberID, permission) values (46, 'Manage Members');
insert into eboardPermissions (eboardMemberID, permission) values (18, 'View Analytics');
insert into eboardPermissions (eboardMemberID, permission) values (40, 'Archive Events');
insert into eboardPermissions (eboardMemberID, permission) values (44, 'Reject Applications');
insert into eboardPermissions (eboardMemberID, permission) values (61, 'Edit Event Details');
insert into eboardPermissions (eboardMemberID, permission) values (61, 'Send Emails');
insert into eboardPermissions (eboardMemberID, permission) values (30, 'Manage Permissions');
insert into eboardPermissions (eboardMemberID, permission) values (32, 'Reject Applications');
insert into eboardPermissions (eboardMemberID, permission) values (40, 'Send Emails');
insert into eboardPermissions (eboardMemberID, permission) values (11, 'Update Member Tiers');
insert into eboardPermissions (eboardMemberID, permission) values (27, 'Delete Events');

-- 22. searchFilters
insert into searchFilters (searchID, filter) values (20, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (14, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (34, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (20, 'Main Campus');
insert into searchFilters (searchID, filter) values (9, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (8, 'Graduate Level');
insert into searchFilters (searchID, filter) values (8, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (30, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (29, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (7, 'Minimum GPA 3.5');
<<<<<<< HEAD
insert into searchFilters (searchID, filter) values (20, 'Main Campus');
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into searchFilters (searchID, filter) values (3, 'Main Campus');
insert into searchFilters (searchID, filter) values (27, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (7, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (28, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (26, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (6, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (35, 'Minimum GPA 3.5');
<<<<<<< HEAD
insert into searchFilters (searchID, filter) values (17, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (32, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (26, 'Minimum GPA 3.0');
=======
insert into searchFilters (searchID, filter) values (32, 'Undergraduate Level');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into searchFilters (searchID, filter) values (30, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (35, 'Main Campus');
insert into searchFilters (searchID, filter) values (10, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (28, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (13, 'Undergraduate Level');
<<<<<<< HEAD
insert into searchFilters (searchID, filter) values (9, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (9, 'Undergraduate Level');
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into searchFilters (searchID, filter) values (29, 'Main Campus');
insert into searchFilters (searchID, filter) values (4, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (2, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (17, 'Main Campus');
<<<<<<< HEAD
insert into searchFilters (searchID, filter) values (3, 'Main Campus');
insert into searchFilters (searchID, filter) values (3, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (24, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (34, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (12, 'Main Campus');
insert into searchFilters (searchID, filter) values (22, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (9, 'Minimum GPA 3.5');
=======
insert into searchFilters (searchID, filter) values (3, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (24, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (12, 'Main Campus');
insert into searchFilters (searchID, filter) values (22, 'Undergraduate Level');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into searchFilters (searchID, filter) values (30, 'Main Campus');
insert into searchFilters (searchID, filter) values (11, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (1, 'Main Campus');
insert into searchFilters (searchID, filter) values (11, 'Main Campus');
insert into searchFilters (searchID, filter) values (35, 'Graduate Level');
insert into searchFilters (searchID, filter) values (20, 'Graduate Level');
<<<<<<< HEAD
insert into searchFilters (searchID, filter) values (26, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (28, 'Minimum GPA 3.5');
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into searchFilters (searchID, filter) values (18, 'Main Campus');
insert into searchFilters (searchID, filter) values (12, 'Graduate Level');
insert into searchFilters (searchID, filter) values (12, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (23, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (25, 'Minimum GPA 3.5');
<<<<<<< HEAD
insert into searchFilters (searchID, filter) values (24, 'Undergraduate Level');
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into searchFilters (searchID, filter) values (5, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (29, 'Graduate Level');
insert into searchFilters (searchID, filter) values (6, 'Graduate Level');
insert into searchFilters (searchID, filter) values (11, 'Graduate Level');
insert into searchFilters (searchID, filter) values (2, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (25, 'Undergraduate Level');
<<<<<<< HEAD
insert into searchFilters (searchID, filter) values (35, 'Graduate Level');
insert into searchFilters (searchID, filter) values (25, 'Main Campus');
insert into searchFilters (searchID, filter) values (29, 'Main Campus');
insert into searchFilters (searchID, filter) values (10, 'Main Campus');
insert into searchFilters (searchID, filter) values (7, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (24, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (22, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (25, 'Main Campus');
insert into searchFilters (searchID, filter) values (3, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (12, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (21, 'Main Campus');
insert into searchFilters (searchID, filter) values (27, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (17, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (26, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (9, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (25, 'Main Campus');
insert into searchFilters (searchID, filter) values (30, 'Main Campus');
insert into searchFilters (searchID, filter) values (18, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (23, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (13, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (17, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (11, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (10, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (6, 'Main Campus');
insert into searchFilters (searchID, filter) values (23, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (34, 'Graduate Level');
insert into searchFilters (searchID, filter) values (25, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (5, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (15, 'Main Campus');
insert into searchFilters (searchID, filter) values (8, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (14, 'Graduate Level');
insert into searchFilters (searchID, filter) values (31, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (14, 'Graduate Level');
insert into searchFilters (searchID, filter) values (21, 'Main Campus');
insert into searchFilters (searchID, filter) values (27, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (19, 'Graduate Level');
insert into searchFilters (searchID, filter) values (31, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (1, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (3, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (26, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (2, 'Graduate Level');
insert into searchFilters (searchID, filter) values (34, 'Graduate Level');
insert into searchFilters (searchID, filter) values (8, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (12, 'Graduate Level');
insert into searchFilters (searchID, filter) values (27, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (1, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (18, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (25, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (4, 'Graduate Level');
insert into searchFilters (searchID, filter) values (23, 'Main Campus');
insert into searchFilters (searchID, filter) values (9, 'Main Campus');
insert into searchFilters (searchID, filter) values (23, 'Graduate Level');
insert into searchFilters (searchID, filter) values (32, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (20, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (18, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (28, 'Main Campus');
insert into searchFilters (searchID, filter) values (34, 'Graduate Level');
insert into searchFilters (searchID, filter) values (14, 'Main Campus');
insert into searchFilters (searchID, filter) values (21, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (9, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (35, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (17, 'Graduate Level');
insert into searchFilters (searchID, filter) values (19, 'Main Campus');
insert into searchFilters (searchID, filter) values (29, 'Main Campus');
insert into searchFilters (searchID, filter) values (8, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (35, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (28, 'Main Campus');
insert into searchFilters (searchID, filter) values (14, 'Graduate Level');
insert into searchFilters (searchID, filter) values (15, 'Minimum GPA 3.5');
insert into searchFilters (searchID, filter) values (6, 'Undergraduate Level');
insert into searchFilters (searchID, filter) values (23, 'Minimum GPA 3.5');
=======
insert into searchFilters (searchID, filter) values (10, 'Main Campus');
insert into searchFilters (searchID, filter) values (22, 'Minimum GPA 3.0');
insert into searchFilters (searchID, filter) values (3, 'Undergraduate Level');
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72


-- 23. updateNotifications
insert into updateNotifications (notification, updateID) values ('New update initiated for security patches', 7);
insert into updateNotifications (notification, updateID) values ('New update initiated for security patches', 3);
insert into updateNotifications (notification, updateID) values ('New version update initiated for performance improvements', 5);
insert into updateNotifications (notification, updateID) values ('New version update initiated for performance improvements', 8);
insert into updateNotifications (notification, updateID) values ('Update in progress for latest features', 5);
insert into updateNotifications (notification, updateID) values ('Update process started for bug fixes', 1);
insert into updateNotifications (notification, updateID) values ('Update process in queue for server enhancements', 3);
insert into updateNotifications (notification, updateID) values ('Update process in queue for server enhancements', 7);
insert into updateNotifications (notification, updateID) values ('New version update initiated for performance improvements', 10);
insert into updateNotifications (notification, updateID) values ('Update process in queue for server enhancements', 4);
insert into updateNotifications (notification, updateID) values ('Software upgrade scheduled for next week', 10);
insert into updateNotifications (notification, updateID) values ('Update in progress for latest features', 1);
insert into updateNotifications (notification, updateID) values ('System update scheduled for tomorrow at 3pm', 3);
insert into updateNotifications (notification, updateID) values ('New update initiated for security patches', 9);
insert into updateNotifications (notification, updateID) values ('System maintenance update scheduled for tonight', 1);
insert into updateNotifications (notification, updateID) values ('Update process started for bug fixes', 4);
<<<<<<< HEAD
insert into updateNotifications (notification, updateID) values ('New version update initiated for performance improvements', 8);
insert into updateNotifications (notification, updateID) values ('New version update initiated for performance improvements', 5);
=======
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into updateNotifications (notification, updateID) values ('Update in progress for latest features', 10);
insert into updateNotifications (notification, updateID) values ('Update started for software version 2.0', 1);
insert into updateNotifications (notification, updateID) values ('System update scheduled for tomorrow at 3pm', 2);
insert into updateNotifications (notification, updateID) values ('New version update initiated for performance improvements', 7);
insert into updateNotifications (notification, updateID) values ('Software update scheduled for the weekend', 3);
insert into updateNotifications (notification, updateID) values ('System update scheduled for tomorrow at 3pm', 10);
insert into updateNotifications (notification, updateID) values ('Update process in queue for server enhancements', 1);
insert into updateNotifications (notification, updateID) values ('Update in progress for latest features', 2);
insert into updateNotifications (notification, updateID) values ('New version update initiated for performance improvements', 6);
<<<<<<< HEAD
insert into updateNotifications (notification, updateID) values ('New version update initiated for performance improvements', 10);
insert into updateNotifications (notification, updateID) values ('Software update scheduled for the weekend', 8);
insert into updateNotifications (notification, updateID) values ('Update process in queue for server enhancements', 6);
insert into updateNotifications (notification, updateID) values ('Software update scheduled for the weekend', 3);
insert into updateNotifications (notification, updateID) values ('System maintenance update scheduled for tonight', 1);
insert into updateNotifications (notification, updateID) values ('Update in progress for latest features', 6);
insert into updateNotifications (notification, updateID) values ('Update process in queue for server enhancements', 9);
insert into updateNotifications (notification, updateID) values ('System update scheduled for tomorrow at 3pm', 3);
=======
insert into updateNotifications (notification, updateID) values ('Software update scheduled for the weekend', 8);
insert into updateNotifications (notification, updateID) values ('Update process in queue for server enhancements', 6);
insert into updateNotifications (notification, updateID) values ('Update in progress for latest features', 6);
insert into updateNotifications (notification, updateID) values ('Update process in queue for server enhancements', 9);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
insert into updateNotifications (notification, updateID) values ('Software update scheduled for the weekend', 5);
insert into updateNotifications (notification, updateID) values ('Update in progress for latest features', 3);
insert into updateNotifications (notification, updateID) values ('New version update initiated for performance improvements', 9);
insert into updateNotifications (notification, updateID) values ('Update process started for bug fixes', 8);
insert into updateNotifications (notification, updateID) values ('New update initiated for security patches', 6);


-- 24. errorAdmin
<<<<<<< HEAD
insert into errorAdmin (adminID, errorID) values (6, 4);
insert into errorAdmin (adminID, errorID) values (5, 9);
insert into errorAdmin (adminID, errorID) values (3, 7);
insert into errorAdmin (adminID, errorID) values (13, 8);
insert into errorAdmin (adminID, errorID) values (9, 2);
insert into errorAdmin (adminID, errorID) values (18, 1);
insert into errorAdmin (adminID, errorID) values (3, 1);
insert into errorAdmin (adminID, errorID) values (17, 1);
insert into errorAdmin (adminID, errorID) values (7, 5);
insert into errorAdmin (adminID, errorID) values (10, 5);
insert into errorAdmin (adminID, errorID) values (16, 6);
insert into errorAdmin (adminID, errorID) values (20, 2);
insert into errorAdmin (adminID, errorID) values (20, 1);
insert into errorAdmin (adminID, errorID) values (8, 6);
insert into errorAdmin (adminID, errorID) values (6, 5);
insert into errorAdmin (adminID, errorID) values (4, 8);
insert into errorAdmin (adminID, errorID) values (9, 4);
insert into errorAdmin (adminID, errorID) values (6, 9);
insert into errorAdmin (adminID, errorID) values (2, 5);
insert into errorAdmin (adminID, errorID) values (4, 8);
insert into errorAdmin (adminID, errorID) values (14, 6);
insert into errorAdmin (adminID, errorID) values (3, 2);
insert into errorAdmin (adminID, errorID) values (3, 8);
insert into errorAdmin (adminID, errorID) values (4, 5);
insert into errorAdmin (adminID, errorID) values (19, 2);
insert into errorAdmin (adminID, errorID) values (17, 6);
insert into errorAdmin (adminID, errorID) values (15, 9);
insert into errorAdmin (adminID, errorID) values (6, 8);
insert into errorAdmin (adminID, errorID) values (3, 4);
insert into errorAdmin (adminID, errorID) values (1, 6);
insert into errorAdmin (adminID, errorID) values (11, 9);
insert into errorAdmin (adminID, errorID) values (14, 1);
insert into errorAdmin (adminID, errorID) values (17, 1);
insert into errorAdmin (adminID, errorID) values (14, 9);
insert into errorAdmin (adminID, errorID) values (16, 2);
insert into errorAdmin (adminID, errorID) values (1, 5);
insert into errorAdmin (adminID, errorID) values (19, 4);
insert into errorAdmin (adminID, errorID) values (1, 1);
insert into errorAdmin (adminID, errorID) values (4, 9);
insert into errorAdmin (adminID, errorID) values (7, 6);
=======
insert into errorAdmin (adminID, errorID) values (13, 35);
insert into errorAdmin (adminID, errorID) values (38, 16);
insert into errorAdmin (adminID, errorID) values (35, 38);
insert into errorAdmin (adminID, errorID) values (3, 3);
insert into errorAdmin (adminID, errorID) values (28, 14);
insert into errorAdmin (adminID, errorID) values (4, 17);
insert into errorAdmin (adminID, errorID) values (36, 26);
insert into errorAdmin (adminID, errorID) values (9, 25);
insert into errorAdmin (adminID, errorID) values (40, 28);
insert into errorAdmin (adminID, errorID) values (30, 18);
insert into errorAdmin (adminID, errorID) values (17, 24);
insert into errorAdmin (adminID, errorID) values (5, 33);
insert into errorAdmin (adminID, errorID) values (15, 36);
insert into errorAdmin (adminID, errorID) values (27, 37);
insert into errorAdmin (adminID, errorID) values (34, 20);
insert into errorAdmin (adminID, errorID) values (6, 23);
insert into errorAdmin (adminID, errorID) values (3, 10);
insert into errorAdmin (adminID, errorID) values (21, 34);
insert into errorAdmin (adminID, errorID) values (12, 3);
insert into errorAdmin (adminID, errorID) values (25, 7);
insert into errorAdmin (adminID, errorID) values (20, 8);
insert into errorAdmin (adminID, errorID) values (20, 15);
insert into errorAdmin (adminID, errorID) values (3, 27);
insert into errorAdmin (adminID, errorID) values (1, 14);
insert into errorAdmin (adminID, errorID) values (36, 9);
insert into errorAdmin (adminID, errorID) values (34, 23);
insert into errorAdmin (adminID, errorID) values (32, 38);
insert into errorAdmin (adminID, errorID) values (12, 5);
insert into errorAdmin (adminID, errorID) values (17, 2);
insert into errorAdmin (adminID, errorID) values (8, 5);
insert into errorAdmin (adminID, errorID) values (14, 15);
insert into errorAdmin (adminID, errorID) values (1, 40);
insert into errorAdmin (adminID, errorID) values (2, 40);
insert into errorAdmin (adminID, errorID) values (35, 21);
insert into errorAdmin (adminID, errorID) values (11, 24);
insert into errorAdmin (adminID, errorID) values (18, 25);
insert into errorAdmin (adminID, errorID) values (8, 35);
insert into errorAdmin (adminID, errorID) values (12, 6);
insert into errorAdmin (adminID, errorID) values (32, 25);
insert into errorAdmin (adminID, errorID) values (5, 27);
>>>>>>> 493f520038da5d8b893e05902931c3c1c7882c72
