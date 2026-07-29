-- =====================================================================
-- Author: ROSHAN KUMAR
-- Project: Sequential Multi-File SQL Project
-- File: 01_schema.sql
-- Description: Establishes the core database structure and defines the 
--              final schema for the production-ready tables.
-- Dependencies: None (First file in the execution sequence).
-- =====================================================================
-- DATABASE CREATION 

DROP DATABASE IF EXISTS world_layoffs;
CREATE DATABASE world_layoffs;
USE world_layoffs;

-- [DATA IMPORT NOTE]
-- The data for the table below was imported using the MySQL Workbench
-- Table Data Import Wizard.
-- File source: ""C:\Users\palla\OneDrive\Desktop\Roshan\World_layoffs_SQL project\layoffs.csv""
-- Target Table: world_layoffs.layoffs

CREATE TABLE `layoffs` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
