/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- ============================================================================
-- Tracks Table
-- ============================================================================
IF OBJECT_ID('bronze.csv_tracks', 'U') IS NOT NULL
    DROP TABLE bronze.csv_tracks;
GO
CREATE TABLE bronze.csv_tracks (
    track_id NVARCHAR(50),
    track_title NVARCHAR(300)
);
GO

-- ============================================================================
-- Courses Table
-- ============================================================================
IF OBJECT_ID('bronze.csv_courses', 'U') IS NOT NULL
    DROP TABLE bronze.csv_courses;
GO
CREATE TABLE bronze.csv_courses (
    course_id NVARCHAR(50),
    track_id NVARCHAR(50),
    course_title NVARCHAR(300)
);
GO

-- ============================================================================
-- Topics Table
-- ============================================================================
IF OBJECT_ID('bronze.csv_topics', 'U') IS NOT NULL
    DROP TABLE bronze.csv_topics;
GO
CREATE TABLE bronze.csv_topics (
    topic_id NVARCHAR(50),
    course_id NVARCHAR(50),
    topic_title NVARCHAR(300)
);
GO

-- ============================================================================
-- Lessons Table
-- ============================================================================
IF OBJECT_ID('bronze.csv_lessons', 'U') IS NOT NULL
    DROP TABLE bronze.csv_lessons;
GO
CREATE TABLE bronze.csv_lessons (
    lesson_id NVARCHAR(50),
    topic_id NVARCHAR(50),
    lesson_title NVARCHAR(300),
    lesson_type NVARCHAR(50),
    duration_in_sec NVARCHAR(50)
);
GO

-- ============================================================================
-- User Registrations Table
-- ============================================================================
IF OBJECT_ID('bronze.csv_user_registrations', 'U') IS NOT NULL
    DROP TABLE bronze.csv_user_registrations;
GO
CREATE TABLE bronze.csv_user_registrations (
    user_id NVARCHAR(50),
    registration_date DATE,
    user_info NVARCHAR(MAX)  -- Raw JSON or string-based user info
);
GO

-- ============================================================================
-- User Lesson Progress Table
-- ============================================================================
IF OBJECT_ID('bronze.csv_user_lesson_progress', 'U') IS NOT NULL
    DROP TABLE bronze.csv_user_lesson_progress;
GO
CREATE TABLE bronze.csv_user_lesson_progress (
    id NVARCHAR(50),
    user_id NVARCHAR(50),
    lesson_id NVARCHAR(50),
    completion_percentage_difference INT,
    overall_completion_percentage INT,
    activity_recorded_datetime_in_utc DATETIMEOFFSET
);
GO

-- ============================================================================
-- User Feedback Table
-- ============================================================================
IF OBJECT_ID('bronze.csv_user_feedback', 'U') IS NOT NULL
    DROP TABLE bronze.csv_user_feedback;
GO
CREATE TABLE bronze.csv_user_feedback (
    id NVARCHAR(50),
    feedback_id NVARCHAR(50),
    creation_datetime DATETIME,
    user_id NVARCHAR(50),
    lesson_id NVARCHAR(50),
    language NVARCHAR(50),
    question NVARCHAR(50),
    answer NVARCHAR(300)
);
GO
