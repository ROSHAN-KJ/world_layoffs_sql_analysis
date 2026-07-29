-- =====================================================================
-- Author: ROSHAN KUMAR
-- Project: Sequential Multi-File SQL Project
-- File: 04_data_analysis.sql
-- Description: Queries the cleaned layoffs production table to answer 
--              key business and economic questions regarding global layoffs.
-- Dependencies: Requires 01_schema.sql, 02_import_staging.sql, and 
--              03_data_cleaning.sql to be executed first.
-- =====================================================================

USE world_layoffs;

------------------------------------------------------------------------
-- SECTION 1: Layoff Trends by Industry
------------------------------------------------------------------------
-- Create a view summarizing total layoffs and companies affected per industry
CREATE OR REPLACE VIEW v_industry_layoffs AS
SELECT industry
    , COUNT(company) AS total_companies_affected
    , SUM(total_laid_off) AS sum_total_laid_off
    , ROUND(AVG(funds_raised_millions), 2) AS avg_funds_raised_millions
FROM layoff_staging2
WHERE industry IS NOT NULL AND industry != ''
GROUP BY industry
ORDER BY sum_total_laid_off DESC;

------------------------------------------------------------------------
-- SECTION 2: Layoffs Over Time (Monthly Trend)
------------------------------------------------------------------------
-- Create a view tracking layoffs month-by-month
CREATE OR REPLACE VIEW v_monthly_layoffs AS
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS layoff_month
    , SUM(total_laid_off) AS monthly_laid_off
    , COUNT(company) AS companies_laying_off
FROM layoff_staging2
WHERE date IS NOT NULL
GROUP BY layoff_month
ORDER BY layoff_month DESC;

------------------------------------------------------------------------
-- SECTION 3: OVERALL IMPACT & TIMELINE
------------------------------------------------------------------------

-- 1. Identify the peak severity of a single layoff event by measuring the maximum employees displaced and the highest corporate workforce reduction percentage in a single day.
SELECT 
    MAX(total_laid_off) AS max_single_day_layoffs
    , MAX(percentage_laid_off) AS max_percentage_laid_off
FROM layoff_staging2;

-- 2. Determine the active chronological timeframe of the dataset to establish the exact boundaries of the economic downturn.
SELECT 
    MIN(date) AS earliest_layoff_date
    , MAX(date) AS latest_layoff_date
FROM layoff_staging2;

------------------------------------------------------------------------
-- SECTION 4: COMPANY & FUNDING IMPACT
------------------------------------------------------------------------

-- 4: Top 10 Companies with the Most Layoffs
SELECT 
    company
    , location
    , industry
    , total_laid_off
    , percentage_laid_off
    , country
FROM layoff_staging2
ORDER BY total_laid_off DESC
LIMIT 10;

-- 5: Layoffs by Country
SELECT 
    country
    , SUM(total_laid_off) AS total_country_layoffs
    , COUNT(company) AS total_companies
FROM layoff_staging2
GROUP BY country
ORDER BY total_country_layoffs DESC;

-- 6. Investigate high-burn or high-capital companies that experienced total organizational failure, resulting in a complete 100% workforce termination ordered by total venture funding raised.
SELECT 
    company
    , location
    , industry
    , total_laid_off
    , funds_raised_millions
    , stage
    , country
FROM layoff_staging2
WHERE percentage_laid_off = 1.0
ORDER BY funds_raised_millions DESC;

-- 7. Calculate aggregate workforce reductions by company to pinpoint the organizations bearing the heaviest cumulative operational toll.
SELECT 
    company
    , SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
GROUP BY company
ORDER BY total_layoffs DESC;

-- 8. Impact on Funding Stage (e.g., Post-IPO, Series A, etc.)
SELECT 
    stage
    , COUNT(company) AS total_companies
    , SUM(total_laid_off) AS total_laid_off
    , ROUND(AVG(funds_raised_millions), 2) AS avg_funds_raised_millions
FROM layoff_staging2
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY total_laid_off DESC;

-- 9. Track longitudinal company performance by calculating yearly cumulative downsizing totals to observe corporate multi-year downscaling trajectories.
SELECT 
    company
    , YEAR(date) AS layoff_year
    , SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
GROUP BY company, YEAR(date)
ORDER BY total_layoffs DESC;

-- 10. Apply advanced analytical window functions to isolate the top 5 highest-impact corporate downsizing events year-over-year.
WITH company_year AS (
    SELECT 
        company
        , YEAR(date) AS years
        , SUM(total_laid_off) AS total_laid_off
    FROM layoff_staging2
    GROUP BY company, YEAR(date)
), 
company_year_rank AS (
    SELECT 
        company
        , years
        , total_laid_off
        , DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
    WHERE years IS NOT NULL
)
SELECT 
    company
    , years
    , total_laid_off
    , ranking
FROM company_year_rank
WHERE ranking <= 5;

------------------------------------------------------------------------
-- SECTION 5: INDUSTRY, COUNTRY & STAGE ANALYSIS
------------------------------------------------------------------------

-- 11. Analyze sector-wide vulnerability by aggregating total layoffs across distinct industries to identify which market domains suffered the most severe structural contraction.
SELECT 
    industry
    , SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
WHERE industry IS NOT NULL AND industry != ''
GROUP BY industry
ORDER BY total_layoffs DESC;

-- 12. Map geographic concentration of the economic shock by evaluating total workforce reductions accumulated at the national level.
SELECT 
    country
    , SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
GROUP BY country
ORDER BY total_layoffs DESC;

-- 13. Evaluate corporate lifecycle vulnerability by assessing which organizational funding or maturity stages experienced the highest volume of workforce cuts.
SELECT 
    stage
    , SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY total_layoffs DESC;

------------------------------------------------------------------------
-- SECTION 6: TIME-SERIES & PROGRESSION TRENDS
------------------------------------------------------------------------

-- 14. Measure macro-economic impact patterns through annual aggregate layoff totals to track year-over-year labor market degradation.
SELECT 
    YEAR(date) AS layoff_year
    , SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
WHERE date IS NOT NULL
GROUP BY YEAR(date)
ORDER BY layoff_year DESC;

-- 15. Breakdown workforce reduction metrics into a chronological monthly distribution to highlight cyclical waves or sudden spikes in market instability.
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS layoff_month
    , SUM(total_laid_off) AS total_layoffs
FROM layoff_staging2
WHERE date IS NOT NULL
GROUP BY layoff_month
ORDER BY layoff_month ASC;

-- 16. Compute a running cumulative total of global layoffs over time using advanced window frames to illustrate the cumulative expansion of the labor crisis.
WITH rolling_total AS (
    SELECT 
        DATE_FORMAT(date, '%Y-%m') AS layoff_month
        , SUM(total_laid_off) AS monthly_total
    FROM layoff_staging2
    WHERE date IS NOT NULL
    GROUP BY layoff_month
)
SELECT 
    layoff_month
    , monthly_total
    , SUM(monthly_total) OVER (ORDER BY layoff_month) AS rolling_total_layoffs
FROM rolling_total;