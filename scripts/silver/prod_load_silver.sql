/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
    Actions Performed:
        - Truncates Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None. 
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        -- Load: silver.csv_lessons
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.csv_lessons';
        TRUNCATE TABLE silver.csv_lessons;
        PRINT '>> Inserting Data Into: silver.csv_lessons';
        INSERT INTO silver.csv_lessons(
            lesson_id,
            topic_id,
            lesson_title,
            lesson_type,
            duration_in_sec)
        SELECT 
            lesson_id,
            ISNULL(topic_id, CASE WHEN lesson_type = 'EXAM' THEN 'TPC00' ELSE NULL END) AS topic_id,
            lesson_title,
            lesson_type,
            duration_in_sec
        FROM bronze.csv_lessons;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Load: silver.csv_topics
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.csv_topics';
        TRUNCATE TABLE silver.csv_topics;
        PRINT '>> Inserting Data Into: silver.csv_topics';
        INSERT INTO silver.csv_topics(
            topic_id,
            course_id,
            topic_title)
        SELECT
            sl.topic_id,
            ISNULL(ct.course_id, CASE WHEN sl.topic_id = 'TPC00' THEN 'CRS00' ELSE NULL END) AS course_id,
            ISNULL(ct.topic_title, CASE WHEN sl.topic_id = 'TPC00' THEN 'N/A' ELSE NULL END) AS topic_title
        FROM silver.csv_lessons sl
        LEFT JOIN bronze.csv_topics ct ON sl.topic_id = ct.topic_id;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Load: silver.csv_courses
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.csv_courses';
        TRUNCATE TABLE silver.csv_courses;
        PRINT '>> Inserting Data Into: silver.csv_courses';
        INSERT INTO silver.csv_courses(
            course_id,
            track_id,
            course_title)
        SELECT
            st.course_id,
            ISNULL(cc.track_id, CASE WHEN st.course_id = 'CRS00' THEN 'TRCK000' ELSE NULL END) AS track_id,
            ISNULL(cc.course_title, CASE WHEN st.course_id = 'CRS00' THEN 'N/A' ELSE NULL END) AS course_title
        FROM silver.csv_topics st
        LEFT JOIN bronze.csv_courses cc ON st.course_id = cc.course_id;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Load: silver.csv_tracks
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.csv_tracks';
        TRUNCATE TABLE silver.csv_tracks;
        PRINT '>> Inserting Data Into: silver.csv_tracks';
        INSERT INTO silver.csv_tracks(
            track_id,
            track_title)
        SELECT
            sc.track_id,
            ISNULL(bt.track_title, CASE WHEN sc.track_id = 'TRCK000' THEN 'N/A' ELSE NULL END) AS track_title
        FROM silver.csv_courses sc
        LEFT JOIN bronze.csv_tracks bt ON sc.track_id = bt.track_id;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Load: silver.csv_user_registrations
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.csv_user_registrations';
        TRUNCATE TABLE silver.csv_user_registrations;
        PRINT '>> Inserting Data Into: silver.csv_user_registrations';
        INSERT INTO silver.csv_user_registrations(
            user_id,
            registration_date,
            city,
            state,
            country,
            highest_degree,
            cgpa,
            gender,
            dob)
        SELECT
            user_id,
            CASE WHEN YEAR(registration_date) = 4000 THEN DATEFROMPARTS(2021, MONTH(registration_date), DAY(registration_date)) ELSE registration_date END,
            city,
            state,
            country,
            highest_degree,
            cgpa,
            UPPER(LEFT(gender, 1)) + LOWER(SUBSTRING(gender, 2, LEN(gender)-1)),
            dob
        FROM bronze.csv_user_registrations;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Load: silver.csv_user_lesson_progress
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.csv_user_lesson_progress';
        TRUNCATE TABLE silver.csv_user_lesson_progress;
        PRINT '>> Inserting Data Into: silver.csv_user_lesson_progress';
        INSERT INTO silver.csv_user_lesson_progress(
            id,
            user_id,
            lesson_id,
            completion_percentage_difference,
            overall_completion_percentage,
            activity_recorded_datetime)
        SELECT
            id,
            user_id,
            lesson_id,
            completion_percentage_difference,
            overall_completion_percentage,
            CAST(activity_recorded_datetime_in_utc AS DATETIME)
        FROM bronze.csv_user_lesson_progress;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- Load: silver.csv_user_feedback
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.csv_user_feedback';
        TRUNCATE TABLE silver.csv_user_feedback;
        PRINT '>> Inserting Data Into: silver.csv_user_feedback';
        INSERT INTO silver.csv_user_feedback(
            id,
            feedback_id,
            creation_datetime,
            user_id,
            lesson_id,
            language,
            question,
            answer)
        SELECT
            id,
            feedback_id,
            creation_datetime,
            user_id,
            lesson_id,
            UPPER(LEFT(language, 1)) + LOWER(SUBSTRING(language, 2, LEN(language) - 1)),
            (
                SELECT STRING_AGG(UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))), '_')
                FROM STRING_SPLIT(question, '_')
            ),
            (
                SELECT STUFF((
                    SELECT ' ' + UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value)))
                    FROM STRING_SPLIT(REPLACE(answer, '"', ''), ' ')
                    WHERE value <> ''
                    FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
            )
        FROM bronze.csv_user_feedback;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';

    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END
