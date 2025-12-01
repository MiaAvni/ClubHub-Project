
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

-- SYSTEM & ADMINISTRATOR DATA


-- System data
INSERT INTO `system` (systemID, version, status, network) VALUES
(1, 'v2.0.1', 'Active', 'Campus Network'),
(2, 'v2.0.1', 'Active', 'Admin Network');


-- Administrator data
INSERT INTO administrator (adminID, systemID, firstName, lastName, email) VALUES
(1, 1, 'John', 'Admin', 'jadmin@northeastern.edu'),
(2, 1, 'Sarah', 'Manager', 'smanager@northeastern.edu');


-- Admin permissions
INSERT INTO adminPermissions (adminID, permission) VALUES
(1, 'Manage Users'),
(1, 'Manage Clubs'),
(2, 'View Reports');


-- Update data
INSERT INTO `update` (updateID, adminID, updateStatus, scheduledTime, startTime, endTime, updateType, availability) VALUES
(1, 1, 'Completed', '2024-11-01 02:00:00', '2024-11-01 02:05:00', '2024-11-01 03:30:00', 'Security Patch', 'System Unavailable'),
(2, 1, 'Scheduled', '2024-12-20 02:00:00', NULL, NULL, 'Feature Deployment', 'Planned Downtime');


-- Update notifications
INSERT INTO updateNotifications (notification, updateID) VALUES
('Security patches applied successfully', 1),
('System maintenance scheduled for Dec 20', 2);


-- Error data
INSERT INTO error (errorID, systemID, updateID, errorType, errorSolution, timeReported, timeSolved) VALUES
(1, 1, 1, 'Database Connection Timeout', 'Increased connection pool size', '2024-11-01 09:15:00', '2024-11-01 10:30:00'),
(2, 1, NULL, 'API Rate Limiting Error', NULL, '2024-11-20 11:30:00', NULL);


-- Error admin assignments
INSERT INTO errorAdmin (adminID, errorID) VALUES
(1, 1),
(1, 2);

-- CATEGORY DATA

INSERT INTO category (categoryID, name) VALUES
(1, 'Computer Science'),
(2, 'Business'),
(3, 'Sports');

-- CLUB DATA

INSERT INTO club (clubID, name, gradLevel, campus, description, numMembers, numSearches) VALUES
(1, 'Computer Science Club', 'Undergraduate', 'Boston', 'For students interested in programming and software development', 120, 450),
(2, 'Entrepreneurship Society', 'Both', 'Boston', 'Supporting student startups and business ventures', 85, 320);

-- Club categories
INSERT INTO clubCategories (clubID, categoryID) VALUES
(1, 1),  -- CS Club -> Computer Science
(2, 2);  -- Entrepreneurship -> Business

-- EBOARD DATA

INSERT INTO eboard (eboardID, clubID, president, vicePresident, secretary, treasurer) VALUES
(1, 1, 'Emma Chen', 'Michael Rodriguez', 'Sarah Kim', 'David Patel'),
(2, 2, 'James Wilson', 'Sofia Martinez', 'Ryan O''Connor', 'Priya Sharma');

-- Admin contacts with eboards
INSERT INTO adminContact (adminID, eboardID) VALUES
(2, 1),
(2, 2);

-- STUDENT DATA


INSERT INTO student (studentID, firstName, lastName, campus, major, minor, age, gender, race, gradYear) VALUES
(1, 'Alex', 'Johnson', 'Boston', 'Computer Science', 'Business Administration', 20, 'Non-binary', 'Asian', 2027),
(2, 'Emma', 'Williams', 'Boston', 'Data Science', 'Mathematics', 21, 'Female', 'White', 2026),
(3, 'Marcus', 'Thompson', 'Boston', 'Business Administration', 'Computer Science', 19, 'Male', 'Black', 2028);

-- Student emails
INSERT INTO studentEmails (studentID, email) VALUES
(1, 'alex.johnson@northeastern.edu'),
(1, 'alex.j.personal@gmail.com'),
(2, 'emma.williams@northeastern.edu'),
(3, 'marcus.thompson@northeastern.edu');

-- EBOARD MEMBERS

INSERT INTO eboardMember (eboardMemberID, studentID, eboardID, position) VALUES
(1, 2, 1, 'President'),
(2, 3, 2, 'Vice President');

-- Eboard member permissions

INSERT INTO eboardPermissions (eboardMemberID, permission) VALUES
(1, 'Manage Members'),
(1, 'Create Events'),
(2, 'Edit Club Info');

-- STUDENT MEMBERSHIPS

-- Student joins

INSERT INTO studentJoins (studentID, clubID, joinDate, memberType) VALUES
(1, 1, '2024-09-05', 'Active Member'),     -- Alex is active in CS Club
(1, 2, '2024-09-08', 'General Member'),    -- Alex is general in Entrepreneurship
(2, 1, '2024-09-03', 'Active Member'),     -- Emma is active in CS Club
(3, 2, '2024-09-04', 'General Member');    -- Marcus is general in Entrepreneurship


-- Student leaves

INSERT INTO studentLeaves (studentID, clubID, leaveDate) VALUES
(2, 2, '2024-10-15'),  -- Emma left a club
(3, 1, '2024-10-20');  -- Marcus left CS Club


-- SEARCH DATA


INSERT INTO search (searchID, studentID, name, dateTime) VALUES
(1, 1, 'tech business clubs', '2024-08-25 14:30:00'),
(2, 1, 'computer science', '2024-08-26 10:15:00');

-- Search filters

INSERT INTO searchFilters (searchID, filter) VALUES
(1, 'Technology'),
(1, 'Business'),
(2, 'Computer Science'),
(2, 'Boston Campus');

-- APPLICATION DATA

INSERT INTO application (applicationID, clubID, studentID, dateSubmitted, status) VALUES
(1, 1, 1, '2024-09-01', 'Accepted'),   -- Alex's application to CS Club
(2, 2, 1, '2024-09-05', 'Pending'),    -- Alex's pending application to Entrepreneurship
(3, 1, 3, '2024-09-03', 'Rejected');   -- Marcus's rejected application

-- EVENT DATA

INSERT INTO `event` (eventID, location, date, description, name, startTime, endTime, capacity, numRegistered, isFull, isArchived, tierRequirement) VALUES
(1, 'Curry Student Center 420', '2024-12-05', 'Learn about machine learning fundamentals', 'ML Workshop', '2024-12-05 18:00:00', '2024-12-05 20:00:00', 50, 35, 0, 0, 'Open'),
(2, 'Richards Hall 235', '2024-12-08', 'Pitch your startup idea', 'Startup Pitch Night', '2024-12-08 19:00:00', '2024-12-08 21:00:00', 80, 62, 0, 0, 'Open'),
(3, 'Curry Student Center', '2024-10-15', 'Past event', 'Python Basics', '2024-10-15 18:00:00', '2024-10-15 20:00:00', 50, 48, 0, 1, 'Open');

-- Club events

INSERT INTO clubEvents (clubID, eventID) VALUES
(1, 1),  -- CS Club hosts ML Workshop
(2, 2),  -- Entrepreneurship hosts Pitch Night
(1, 3);  -- CS Club hosted Python event


-- Student event registrations

INSERT INTO studentEvents (studentID, eventID) VALUES
(1, 1),  -- Alex registered for ML Workshop
(1, 2),  -- Alex registered for Pitch Night
(2, 1),  -- Emma registered for ML Workshop
(3, 2);  -- Marcus registered for Pitch Night
