-- Data Science Salaries 2023: SQL queries (PostgreSQL)
-- Table `salaries` is the raw Kaggle data (3,755 rows).
-- Column names used below: exp_level, emp_type, job_title, salary_in_usd,
--   remote_ratio, company_location, company_size.

-- 1. Cleaning: remove exact duplicate rows (3,755 -> 2,584)
CREATE TABLE salaries_clean AS
SELECT DISTINCT * FROM salaries;


-- 2. Office vs remote by experience level (all countries, full-time)
SELECT exp_level, remote_ratio,
       COUNT(*) AS n,
       ROUND(AVG(salary_in_usd)) AS avg_usd,
       ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_in_usd))::numeric) AS median_usd
FROM salaries_clean
WHERE emp_type = 'FT'
GROUP BY exp_level, remote_ratio
ORDER BY exp_level, remote_ratio;


-- 3. Countries (full-time, at least 30 records)
SELECT company_location,
       COUNT(*) AS n,
       ROUND(AVG(salary_in_usd)) AS avg_usd,
       ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_in_usd))::numeric) AS median_usd
FROM salaries_clean
WHERE emp_type = 'FT'
GROUP BY company_location
HAVING COUNT(*) >= 30
ORDER BY median_usd DESC;


-- 4. Office vs remote within the US only (check whether country explains the gap)
SELECT exp_level, remote_ratio,
       COUNT(*) AS n,
       ROUND(AVG(salary_in_usd)) AS avg_usd,
       ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_in_usd))::numeric) AS median_usd
FROM salaries_clean
WHERE emp_type = 'FT'
  AND company_location = 'US'
  AND remote_ratio IN (0, 100)
GROUP BY exp_level, remote_ratio
ORDER BY exp_level, remote_ratio;


-- 5. Company size by experience level (US, full-time)
SELECT company_size, exp_level,
       COUNT(*) AS n,
       ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_in_usd))::numeric) AS median_usd
FROM salaries_clean
WHERE emp_type = 'FT'
  AND company_location = 'US'
GROUP BY company_size, exp_level
ORDER BY exp_level, company_size;


-- 6. Job titles with at least 30 records, ranked by median (CTE + window function)
WITH title_stats AS (
    SELECT job_title,
           COUNT(*) AS n,
           ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_in_usd))::numeric) AS median_usd
    FROM salaries_clean
    WHERE emp_type = 'FT'
      AND company_location = 'US'
    GROUP BY job_title
    HAVING COUNT(*) >= 30
)
SELECT job_title, n, median_usd,
       DENSE_RANK() OVER (ORDER BY median_usd DESC) AS rnk
FROM title_stats
ORDER BY rnk;


-- 7. Data Analyst vs Data Scientist vs Data Engineer by experience level
SELECT job_title, exp_level,
       COUNT(*) AS n,
       ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_in_usd))::numeric) AS median_usd
FROM salaries_clean
WHERE emp_type = 'FT'
  AND company_location = 'US'
  AND job_title IN ('Data Analyst', 'Data Scientist', 'Data Engineer')
GROUP BY job_title, exp_level
ORDER BY exp_level, job_title;


-- 8. Export for Tableau: readable labels for experience level and work mode
SELECT *,
       CASE exp_level
            WHEN 'EN' THEN 'Entry'
            WHEN 'MI' THEN 'Mid'
            WHEN 'SE' THEN 'Senior'
            WHEN 'EX' THEN 'Executive'
       END AS exp_label,
       CASE remote_ratio
            WHEN 0 THEN 'Office'
            WHEN 50 THEN 'Hybrid'
            WHEN 100 THEN 'Remote'
       END AS work_mode
FROM salaries_clean;
