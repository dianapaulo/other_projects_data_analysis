
-- DATA CLEANING -- 
/*  
THINGS TO DO FOR DATA CLEANING
1.REMOVE THE DUPLICATES
2.STANDARDIZE THE DATA 
3.LOOK FOR NULL OR BLANK VALUES
4.REMOVE COLUMNS THAT ARE NOT NECESSARY 
*/
-- IF YOU ARE IN  DIRECT SCHEMA DATABASE SELECT * FROM layoffs; IF NOT, SELECT * FROM world_layoffs.layoffs; MENTION THE DB NAME


SELECT *
FROM layoffs;

-- CREATE ANOTHER TABLE FOR LAYOFFS  called layoffs_staging (2ND COPY)  to SAVE THE RaW DATA
CREATE TABLE layoffs_staging 
LIKE layoffs;  -- it will copy all the column from layoffs table

SELECT *
FROM layoffs_staging ;  -- check the new table 

INSERT layoffs_staging -- insert all the data from  layoffs to layoffs_staging 
SELECT * 
FROM layoffs;

SELECT *
FROM layoffs_staging ;  -- check the data

-- -------------------------------------------------------------------------------------------------
-- 1.REMOVE THE DUPLICATES 

/*
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;
*/

-- USE CTE 
WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num -- (for date i use back tick)
FROM layoffs_staging
)
 -- it will show duplicates 
SELECT * 
FROM duplicate_cte
WHERE row_num > 1; 

SELECT *
FROM layoffs_staging
WHERE company = 'Oda'; -- double check first if it is really duplicate before deleting 

-- oda is not duplicate
-- edit the CTE above then we do partition by all columns  

WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num -- (for date i use back tick)
FROM layoffs_staging
)
 -- it will show duplicates 
SELECT * 
FROM duplicate_cte
WHERE row_num > 1; 

SELECT *
FROM layoffs_staging
WHERE company = 'Casper'; -- double check first if it is really duplicate before deleting

--  solution in deleting duplicates
--  create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column
--  right click on layoff_staging table-copy to clipboard-create statement-paste

-- rename layoffs_staging to layoffs_staging_2
-- add new column row_num
CREATE TABLE `layoffs_staging_2` (
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


SELECT *
FROM layoffs_staging_2;-- now we have a new table called  layoffs_staging_2  with added column row_num

-- insert all the data
INSERT INTO layoffs_staging_2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company,location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoffs_staging;

SELECT *
FROM layoffs_staging_2
WHERE row_num > 1;

--  deleting duplicates

SET SQL_SAFE_UPDATES = 0;

DELETE
FROM layoffs_staging_2
WHERE row_num > 1;

/*
delete is not working go to 
Edit-> Preferences-> SQL Editor -> and deselect the option "Safe Edits". restart mysql
OR no need to re start go to Query on the top left side of your window then select reconnect to server and then run your query.
Or just run the command "SET SQL_SAFE_UPDATES = 0;" Didn't need to reconnect or anything with this.
*/

-- double check if there are still duplicate rows
SELECT *
FROM layoffs_staging_2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging_2;


-- -------------------------------------------------------------------------------------------------
-- 2. STANDARDIZE DATA 

-- TRIM allows you to easily remove white spaces from a string in a database

SELECT company, TRIM(company)
FROM layoffs_staging_2;

-- update company
UPDATE layoffs_staging_2
SET company = TRIM(company);

-- check  for industry
SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY 1; -- 1 means first column

-- problems for industry there is blanck space, null, crypto and crypto currency should be the same thing

SELECT industry
FROM layoffs_staging_2
WHERE industry LIKE 'Crypto%'; 

UPDATE layoffs_staging_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT *
FROM layoffs_staging_2
WHERE industry LIKE 'Crypto%'; -- no more crypto currency rename all in crypto

SELECT DISTINCT industry -- double check for industry
FROM layoffs_staging_2
ORDER BY industry;

SELECT *
FROM layoffs_staging_2;

-- check location
SELECT DISTINCT location
FROM layoffs_staging_2
ORDER BY 1; 
-- LOCATION all GOOD

-- check country
SELECT DISTINCT country
FROM layoffs_staging_2
ORDER BY 1; 

-- Problem there are two United States  and United States. with dot at the end 
-- to fix the problem 

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging_2
ORDER BY 1; 

UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_staging_2; 

-- date is in text  so we need to change the format 
SELECT `date`
FROM layoffs_staging_2; 

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging_2; 

UPDATE layoffs_staging_2
SET `date`= STR_TO_DATE(`date`, '%m/%d/%Y'); -- date still in text(string) 

-- change format into DATE FORMAT
ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging_2; 

-- -------------------------------------------------------------------------------------------------
-- 3. LOOK FOR NULL OR BLANK VALUES 
 
SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

UPDATE layoffs_staging_2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging_2
WHERE industry IS NULL
OR industry = ''; 

-- populate the data example in airbnb 
SELECT *
FROM layoffs_staging_2
WHERE company = 'Airbnb'; -- airbnb industry is travel so the other blank airbnb industry  we should fill it travel too. 

SELECT t1.industry, t2.industry
FROM layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
WHERE  (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

-- update industry 
UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- double check again if all is populated
SELECT *
FROM layoffs_staging_2
WHERE industry IS NULL
OR industry = '';  
-- here bally company still null 

SELECT *
FROM layoffs_staging_2
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging_2;

-- -------------------------------------------------------------------------------------------------
-- 4. REMOVE COLUMNS OR ROWS THAT ARE NOT NECESSARY

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

SELECT *
FROM layoffs_staging_2;

DELETE 
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

SELECT *
FROM layoffs_staging_2;

-- remove column row_num
ALTER TABLE layoffs_staging_2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging_2;


