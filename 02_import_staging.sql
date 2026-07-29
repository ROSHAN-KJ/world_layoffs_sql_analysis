-- =====================================================================
-- Author: ROSHAN KUMAR
-- Project: Sequential Multi-File SQL Project
-- File: 02_import_staging.sql
-- Description: Creates the raw staging table designed to catch unparsed 
--              text data straight from the CSV import wizard.
-- Dependencies: Requires 01_schema.sql to be executed first.
-- =====================================================================

USE world_layoffs;

-- CREATE STAGING TABLE
CREATE TABLE layoff_staging
LIKE layoffs;

INSERT layoff_staging
SELECT *
FROM layoffs;
-- NOTE: Execute your MySQL Workbench Table Data Import Wizard on the layoffs table.