/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.

    The Gold layer follows a Snowflake Schema design, consisting of:
        - Dimension views that capture descriptive attributes
        - Fact views that record measurable events
        - Aggregated views for enhanced analytics and performance

    All views are derived from the cleansed and structured Silver layer tables,
    presenting a business-ready, analytics-friendly model.

Usage:
    - Supports BI dashboards, reporting, and ad-hoc analytics
    - Serves as the foundation for insights into user engagement,
      learning progress, and feedback patterns

    These views are designed to be intuitive for business users and optimized
    for performance across downstream tools.
===============================================================================
*/

-- Fact Views
IF OBJECT_ID('gold.fact_user_lesson_progress', 'V') IS NOT NULL DROP VIEW gold.fact_user_lesson_progress;
GO
CREATE VIEW gold.fact_user_lesson_progress AS
SELECT 
    id,
    user_id,
    lesson_id,
    completion_percentage_difference,
    overall_completion_percentage,
    activity_recorded_datetime
FROM silver.csv_user_lesson_progress;
GO

IF OBJECT_ID('gold.fact_user_feedback', 'V') IS NOT NULL DROP VIEW gold.fact_user_feedback;
GO
CREATE VIEW gold.fact_user_feedback AS
SELECT
    id,
    feedback_id,
    user_id,
    lesson_id,
    language,
    question,
    answer,
    creation_datetime
FROM silver.csv_user_feedback;
GO

-- Dimension Views
IF OBJECT_ID('gold.dim_user_registrations', 'V') IS NOT NULL DROP VIEW gold.dim_user_registrations;
GO
CREATE VIEW gold.dim_user_registrations AS
SELECT
    user_id,
    city,
    state,
    country,
    highest_degree,
    cgpa,
    gender,
    dob AS date_of_birth,
    registration_date
FROM silver.csv_user_registrations;
GO

IF OBJECT_ID('gold.dim_lessons', 'V') IS NOT NULL DROP VIEW gold.dim_lessons;
GO
CREATE VIEW gold.dim_lessons AS
SELECT
    lesson_id,
    topic_id,
    lesson_title,
    lesson_type,
    duration_in_sec
FROM silver.csv_lessons;
GO

IF OBJECT_ID('gold.dim_topics', 'V') IS NOT NULL DROP VIEW gold.dim_topics;
GO
CREATE VIEW gold.dim_topics AS
SELECT
    topic_id,
    course_id,
    topic_title
FROM silver.csv_topics;
GO

IF OBJECT_ID('gold.dim_courses', 'V') IS NOT NULL DROP VIEW gold.dim_courses;
GO
CREATE VIEW gold.dim_courses AS
SELECT
    course_id,
    track_id,
    course_title
FROM silver.csv_courses;
GO

IF OBJECT_ID('gold.dim_tracks', 'V') IS NOT NULL DROP VIEW gold.dim_tracks;
GO
CREATE VIEW gold.dim_tracks AS
SELECT
    track_id,
    track_title
FROM silver.csv_tracks;
GO

IF OBJECT_ID('gold.dim_content_structure', 'V') IS NOT NULL DROP VIEW gold.dim_content_structure;
GO
CREATE VIEW gold.dim_content_structure AS
SELECT
    sl.lesson_id,
    sl.topic_id,
    st.course_id,
    sl.lesson_title,
    sl.lesson_type,
    sl.duration_in_sec,
    st.topic_title,
    sc.course_title,
    ct.track_title
FROM silver.csv_lessons sl
LEFT JOIN silver.csv_topics st ON sl.topic_id = st.topic_id
LEFT JOIN silver.csv_courses sc ON st.course_id = sc.course_id
LEFT JOIN silver.csv_tracks ct ON sc.track_id = ct.track_id;
GO

-- Aggregate Views
IF OBJECT_ID('gold.agg_day_and_lesson_wise_user_activity', 'V') IS NOT NULL DROP VIEW gold.agg_day_and_lesson_wise_user_activity;
GO
CREATE VIEW gold.agg_day_and_lesson_wise_user_activity AS
SELECT
    user_id,
    lesson_id,
    CAST(activity_recorded_datetime AS DATE) AS activity_date,
    MAX(overall_completion_percentage) AS daily_completion_percentage
FROM silver.csv_user_lesson_progress
GROUP BY
    user_id,
    lesson_id,
    CAST(activity_recorded_datetime AS DATE);
GO

IF OBJECT_ID('gold.agg_user_learning_streaks', 'V') IS NOT NULL DROP VIEW gold.agg_user_learning_streaks;
GO
SET DATEFIRST 7;
GO
CREATE VIEW gold.agg_user_learning_streaks AS
WITH user_activity_dates AS (
    SELECT 
        user_id,
        CAST(activity_recorded_datetime AS DATE) AS activity_date
    FROM silver.csv_user_lesson_progress
    GROUP BY user_id, CAST(activity_recorded_datetime AS DATE)
),
calendar_cte AS (
    SELECT 
        MIN(CAST(activity_recorded_datetime AS DATE)) AS start_date,
        MAX(CAST(activity_recorded_datetime AS DATE)) AS end_date
    FROM silver.csv_user_lesson_progress
),
date_series AS (
    SELECT DATEADD(DAY, sv.number, c.start_date) AS calendar_date
    FROM master.dbo.spt_values sv
    CROSS JOIN calendar_cte c
    WHERE sv.type = 'P'
      AND sv.number <= DATEDIFF(DAY, c.start_date, c.end_date)
),
user_full_dates AS (
    SELECT u.user_id, d.calendar_date
    FROM (SELECT DISTINCT user_id FROM user_activity_dates) u
    CROSS JOIN date_series d
),
user_merged AS (
    SELECT 
        f.user_id,
        f.calendar_date,
        CASE WHEN a.activity_date IS NOT NULL THEN 1 ELSE 0 END AS did_activity
    FROM user_full_dates f
    LEFT JOIN user_activity_dates a 
        ON f.user_id = a.user_id AND f.calendar_date = a.activity_date
),
streak_grouping AS (
    SELECT *,
        SUM(
            CASE 
                WHEN did_activity = 0 AND DATEPART(WEEKDAY, calendar_date) != 1 THEN 1
                ELSE 0 
            END
        ) OVER (
            PARTITION BY user_id 
            ORDER BY calendar_date 
            ROWS UNBOUNDED PRECEDING
        ) AS break_count
    FROM user_merged
),
final_streaks AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, break_count 
            ORDER BY calendar_date
        ) AS streak_day_number
    FROM streak_grouping
    WHERE did_activity = 1
)
SELECT 
    user_id,
    calendar_date AS activity_date,
    break_count AS streak_group_id,
    streak_day_number
FROM final_streaks;
GO

IF OBJECT_ID('gold.agg_course_wise_user_completion_percentages', 'V') IS NOT NULL DROP VIEW gold.agg_course_wise_user_completion_percentages;
GO
CREATE VIEW gold.agg_course_wise_user_completion_percentages AS
WITH lesson_course_mapping AS (
    SELECT 
        l.lesson_id,
        c.course_id
    FROM silver.csv_lessons l
    JOIN silver.csv_topics t ON l.topic_id = t.topic_id
    JOIN silver.csv_courses c ON t.course_id = c.course_id
),
user_lesson_progress AS (
    SELECT 
        ulp.user_id,
        lcm.course_id,
        ulp.lesson_id,
        MAX(ulp.overall_completion_percentage) AS max_completion
    FROM silver.csv_user_lesson_progress ulp
    JOIN lesson_course_mapping lcm ON ulp.lesson_id = lcm.lesson_id
    GROUP BY ulp.user_id, lcm.course_id, ulp.lesson_id
),
course_lesson_counts AS (
    SELECT 
        course_id,
        COUNT(DISTINCT lesson_id) AS total_lessons
    FROM lesson_course_mapping
    GROUP BY course_id
),
user_course_completion AS (
    SELECT 
        ulp.user_id,
        ulp.course_id,
        SUM(CASE WHEN ulp.max_completion >= 100 THEN 1 ELSE 0 END) AS completed_lessons
    FROM user_lesson_progress ulp
    GROUP BY ulp.user_id, ulp.course_id
)
SELECT 
    ucc.user_id,
    ucc.course_id,
    CAST(1.0 * ucc.completed_lessons / clc.total_lessons * 100 AS DECIMAL(5,2)) AS course_completion_percentage
FROM user_course_completion ucc
JOIN course_lesson_counts clc ON ucc.course_id = clc.course_id;
GO

IF OBJECT_ID('gold.agg_user_feedback_details', 'V') IS NOT NULL DROP VIEW gold.agg_user_feedback_details;
GO
CREATE VIEW gold.agg_user_feedback_details AS
SELECT 
    user_id,
    lesson_id,
    MAX(CASE WHEN question = 'RATING' THEN answer END) AS rating,
    MAX(CASE WHEN question = 'LIKED' THEN answer END) AS liked,
    MAX(CASE WHEN question = 'BETTER_TO_IMPROVE' THEN answer END) AS better_to_improve,
    MAX(CASE WHEN question = 'OTHER' THEN answer END) AS other_feedback,
    MIN(creation_datetime) AS feedback_timestamp
FROM silver.csv_user_feedback
GROUP BY user_id, lesson_id;
GO

IF OBJECT_ID('gold.dim_user_demographics_details', 'V') IS NOT NULL DROP VIEW gold.dim_user_demographics_details;
GO
CREATE VIEW gold.dim_user_demographics_details AS
SELECT
    user_id,
    city,
    state,
    country,
    gender,
    dob,
    highest_degree,
    cgpa,
    registration_date
FROM silver.csv_user_registrations;
GO
