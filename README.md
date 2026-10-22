# Data Science Salaries: what drives pay?

SQL analysis and an interactive dashboard on the Kaggle "Data Science Salaries 2023" dataset.

**Live dashboard:** [Tableau Public](https://public.tableau.com/app/profile/yehor.kryklyvyi/viz/salary_dashboard_public/Salarydriversdashboard)

## Goal

Find out which factors are associated with higher salaries in data roles: country, experience level, work format (office / remote), company size and job title. A separate question I cared about as a future junior analyst: how do Data Analyst salaries compare with other data roles at the same experience level?

## Data

- Source: Kaggle, *Data Science Salaries 2023* (3,755 rows, 11 columns, no missing values).
- The dataset has no ID column and contains many repeated records. I removed exact duplicates with `SELECT DISTINCT`: **3,755 → 2,584 rows** (1,171 extra copies removed).
- More than 92% of records are from 2022–2023, so the results describe the recent market, not a long-term trend.
- Analysis is restricted to full-time employees (`emp_type = 'FT'`) unless stated otherwise.

## Tools

PostgreSQL (pgAdmin 4) for cleaning and analysis, Tableau Public for the dashboard.

SQL techniques used: `GROUP BY` / `HAVING`, `CASE WHEN`, CTE (`WITH`), window functions (`DENSE_RANK`), `PERCENTILE_CONT` for medians.

## Method notes

- **Median instead of mean.** Salary data is right-skewed, so medians are reported.
- **Minimum sample size.** Groups with fewer than 30 records (countries, job titles) are excluded; groups with fewer than 10 records are not interpreted.
- **Checking for confounders.** Before accepting a difference I checked whether it could be explained by something else (for example, by country or experience level).

## Key findings

1. **Country is the biggest factor.** Median full-time salary of companies in the US is $146K, in Canada $120K, in the UK $80K, in Germany $74K, in France $59K, in Spain $48K and in India $19K. The US makes up about 82% of the records in these countries.
2. **Pay rises with experience** (US, full-time): Entry $90K, Mid $125K, Senior $154K, Executive $200K.
3. **Office vs remote matters mainly at entry level.** For US full-time employees: Entry $120K (office) vs $80K (remote), Mid $126K vs $120K, Senior $153K vs $155K, Executive $196K vs $204K.
   - In all countries combined the office premium at Mid level was 17%. Within the US it falls to about 5%, so country explained most of it.
   - Entry level still shows a large gap within the US, but the groups are small (about 55 records each), so this is a hint, not a proven effect.
4. **Company size has no consistent effect.** Large companies pay more at Senior level, medium companies at Mid level, and entry-level pay is similar for all sizes. Medium companies make up most of the data.
5. **Data Analyst has the lowest median of the 9 roles with 30+ records** (US, full-time): $111K vs $150K for Data Scientist and Data Engineer. The gap holds within every experience level where there is enough data:

   | Level | Data Analyst | Data Engineer | Data Scientist |
   |---|---|---|---|
   | Entry | $64K | $85K | $97K |
   | Mid | $105K | $120K | $120K |
   | Senior | $120K | $155K | $159K |

## Limitations

- The data is dominated by US companies; results for other countries rest on 32–155 records per country.
- These are associations, not causes. For example, the data cannot show that working remotely lowers pay.
- Salaries are US-market levels. They should not be compared directly with Ukrainian salaries.
- Executive-level groups are small, and Data Analyst has only 2 executive records, so that level is not interpreted.

## Repository

- `queries.sql` — all SQL queries in the order they were run.
- `README.md` — this file.
- Dashboard: see the Tableau Public link above.
