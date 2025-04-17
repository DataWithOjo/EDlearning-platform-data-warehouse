/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'edtech_dw' after checking if it already exists. 
    If the database exists, it is dropped and recreated. It also sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.

⚠️ WARNING:
    Running this script will drop the entire 'edtech_dw' database if it exists. 
    All data will be permanently deleted. Ensure you have backups before executing.
=============================================================
*/

USE master;
GO

-- Drop and recreate the 'edtech_dw' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'edtech_dw')
BEGIN
    ALTER DATABASE edtech_dw SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE edtech_dw;
END;
GO

-- Create the 'edtech_dw' database
CREATE DATABASE edtech_dw;
GO

-- Switch to the new database
USE edtech_dw;
GO

-- Create Medallion Architecture Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
