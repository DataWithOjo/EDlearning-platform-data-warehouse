/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source CSV Files → Bronze Tables)
===============================================================================
Script Purpose:
    This stored procedure handles the initial ingestion of raw data into the 
    Bronze layer of the data warehouse using the Medallion Architecture pattern.

    Specifically, it performs the following actions:
    - Truncates all existing tables in the 'bronze' schema to ensure clean loads.
    - Uses the `BULK INSERT` command to load cleaned CSV files into their 
      respective bronze tables.
    - Ensures data consistency between the structure of CSV files and the 
      schema definition of the bronze tables.

Parameters:
    None.
    This procedure does not take any input parameters or return output values.

Usage Example:
    EXEC bronze.load_bronze;

Notes:
    - This process is the first step in the data pipeline and is intended to 
      ingest raw-but-cleaned data (preprocessed using Python) into the Bronze layer.
    - Ensure all cleaned CSVs are saved in the designated import folder with 
      the correct schema before execution.
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.csv_tracks';
		TRUNCATE TABLE bronze.csv_tracks;
		PRINT '>> Inserting Data Into: bronze.csv_tracks';
		BULK INSERT bronze.csv_tracks
		FROM 'C:\Users\USER\Documents\kaggle_analytical_engineer\track_table.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.csv_courses';
		TRUNCATE TABLE bronze.csv_courses;
		PRINT '>> Inserting Data Into: bronze.csv_courses';
		BULK INSERT bronze.csv_courses
		FROM 'C:\Users\USER\Documents\kaggle_analytical_engineer\course_table.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.csv_topics';
		TRUNCATE TABLE bronze.csv_topics;
		PRINT '>> Inserting Data Into: bronze.csv_topics';
		BULK INSERT bronze.csv_topics
		FROM 'C:\Users\USER\Documents\kaggle_analytical_engineer\topic_table.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.csv_lessons';
		TRUNCATE TABLE bronze.csv_lessons;
		PRINT '>> Inserting Data Into: bronze.csv_lessons';
		BULK INSERT bronze.csv_lessons
		FROM 'C:\Users\USER\Documents\kaggle_analytical_engineer\lesson_table_cleaned.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.csv_user_registrations';
		TRUNCATE TABLE bronze.csv_user_registrations;
		PRINT '>> Inserting Data Into: bronze.csv_user_registrations';
		BULK INSERT bronze.csv_user_registrations
		FROM 'C:\Users\USER\Documents\kaggle_analytical_engineer\user_registrations_cleaned.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.csv_user_lesson_progress';
		TRUNCATE TABLE bronze.csv_user_lesson_progress;
		PRINT '>> Inserting Data Into: bronze.csv_user_lesson_progress';
		BULK INSERT bronze.csv_user_lesson_progress
		FROM 'C:\Users\USER\Documents\kaggle_analytical_engineer\user_lesson_progress_log.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.csv_user_feedback';
		TRUNCATE TABLE bronze.csv_user_feedback;
		PRINT '>> Inserting Data Into: bronze.csv_user_feedback';
		BULK INSERT bronze.csv_user_feedback
		FROM 'C:\Users\USER\Documents\kaggle_analytical_engineer\user_feedback.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
