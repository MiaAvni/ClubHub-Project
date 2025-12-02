
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

USE ClubHub;

