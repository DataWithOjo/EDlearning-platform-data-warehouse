/*
===============================================================================
DDL Script: Create silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
    Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

-- ============================================================================
-- Tracks Table
-- ============================================================================
IF OBJECT_ID('silver.csv_tracks', 'U') IS NOT NULL
    DROP TABLE silver.csv_tracks;
GO
CREATE TABLE silver.csv_tracks (
    track_id NVARCHAR(50),
    track_title NVARCHAR(300),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================================
-- Courses Table
-- ============================================================================
IF OBJECT_ID('silver.csv_courses', 'U') IS NOT NULL
    DROP TABLE silver.csv_courses;
GO
CREATE TABLE silver.csv_courses (
    course_id NVARCHAR(50),
    track_id NVARCHAR(50),
    course_title NVARCHAR(300),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================================
-- Topics Table
-- ============================================================================
IF OBJECT_ID('silver.csv_topics', 'U') IS NOT NULL
    DROP TABLE silver.csv_topics;
GO
CREATE TABLE silver.csv_topics (
    topic_id NVARCHAR(50),
    course_id NVARCHAR(50),
    topic_title NVARCHAR(300),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================================
-- Lessons Table
-- ============================================================================
IF OBJECT_ID('silver.csv_lessons', 'U') IS NOT NULL
    DROP TABLE silver.csv_lessons;
GO
CREATE TABLE silver.csv_lessons (
    lesson_id NVARCHAR(50),
    topic_id NVARCHAR(50),
    lesson_title NVARCHAR(300),
    lesson_type NVARCHAR(50),
    duration_in_sec INT,
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================================
-- User Registrations Table
-- ============================================================================
IF OBJECT_ID('silver.csv_user_registrations', 'U') IS NOT NULL
    DROP TABLE silver.csv_user_registrations;
GO
CREATE TABLE silver.csv_user_registrations (
    user_id NVARCHAR(50),
    registration_date DATE,
    city NVARCHAR(50),
    state NVARCHAR(50),
    country NVARCHAR(50),
    highest_degree NVARCHAR(50),
    cgpa DECIMAL(3,1),
    gender NVARCHAR(50),
    dob DATE,
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================================
-- User Lesson Progress Table
-- ============================================================================
IF OBJECT_ID('silver.csv_user_lesson_progress', 'U') IS NOT NULL
    DROP TABLE silver.csv_user_lesson_progress;
GO
CREATE TABLE silver.csv_user_lesson_progress (
    id NVARCHAR(50),
    user_id NVARCHAR(50),
    lesson_id NVARCHAR(50),
    completion_percentage_difference INT,
    overall_completion_percentage INT,
    activity_recorded_datetime DATETIME,
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================================
-- User Feedback Table
-- ============================================================================
IF OBJECT_ID('silver.csv_user_feedback', 'U') IS NOT NULL
    DROP TABLE silver.csv_user_feedback;
GO
CREATE TABLE silver.csv_user_feedback (
    id NVARCHAR(50),
    feedback_id NVARCHAR(50),
    creation_datetime DATETIME,
    user_id NVARCHAR(50),
    lesson_id NVARCHAR(50),
    language NVARCHAR(50),
    question NVARCHAR(50),
    answer NVARCHAR(300),
	dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO
