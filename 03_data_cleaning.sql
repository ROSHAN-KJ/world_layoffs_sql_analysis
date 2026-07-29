-- =====================================================================
-- Author: ROSHAN KUMAR
-- Project: Sequential Multi-File SQL Project
-- File: 03_data_cleaning.sql
-- Description: Performs data hygiene operations, removes duplicates, 
--              handles missing values, and standardizes formats from the 
--              raw staging table into the production environment.
-- Dependencies: Requires 01_schema.sql and 02_import_staging.sql 
--              (with imported CSV data) to be executed first.
-- =====================================================================

USE world_layoffs;

-- DATA CLEANING 
-- REMOVE DUPLICATES
-- Use Row_number to check for duplicates, as this table does not have any primary key
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY 
			company
			, location
			, industry
			, total_laid_off
			, percentage_laid_off
			, `date`
			, stage
			, country
			, funds_raised_millions
	) AS row_num
FROM layoff_staging;

-- Use CTE to confirm the duplicates
WITH duplicate_cte AS 
(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY 
			company
            , location
            , industry
            , total_laid_off
            , percentage_laid_off
            , `date`
            , stage
            , country
            , funds_raised_millions
	) AS row_num
FROM layoff_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;

SELECT * 
FROM layoff_staging
WHERE company = 'Casper';

-- Since MySQL Workbench does not allow to directly delete any rows
-- Create a new table with an extra column for row_num, filter out, and delete the duplicate rows
CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_staging2
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY 
			company
			, location
			, industry
			, total_laid_off
			, percentage_laid_off
			, `date`
			, stage
			, country
			, funds_raised_millions
	) AS row_num
FROM layoff_staging
;

SELECT *
FROM layoff_staging2
;

DELETE 
FROM layoff_staging2
WHERE row_num > 1;

-- STANDARDIZING DATA 
SELECT 
	company
	, TRIM(company)
FROM layoff_staging2;

UPDATE layoff_staging2
SET company = TRIM(company);

SELECT *
FROM layoff_staging2;

SELECT *
FROM layoff_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoff_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoff_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Change dates from varchar to date format
SELECT 
	`date`
	, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoff_staging2;

UPDATE layoff_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;

-- Find out the NULL or Blank Value
SELECT *
FROM layoff_staging2
WHERE industry IS NULL
OR industry = '';

-- Convert the blank values into null
UPDATE layoff_staging2
SET industry = NULL
WHERE industry = '';

-- Use the SELF JOIN to find and later update the missing industry values
SELECT t1.industry, t2.industry
FROM layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoff_staging2 t1
JOIN layoff_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Since there is large number of rows which do not have any total_laid_off or percentage_laid_off 
-- Delete the the rows that do not have any total_laid_off or percentage_laid_off 
SELECT *
FROM layoff_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Remove the row_num column that was added

ALTER TABLE layoff_staging2
DROP COLUMN row_num;