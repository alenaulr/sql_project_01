# SQL Project – Food Accessibility Analysis (CZ)

## Project Overview
This project prepares analytical data for evaluating food affordability in the Czech Republic based on the relationship between average wages and food prices over time.

The project outputs:
1. a **primary final table** combining Czech wages and food prices for comparable years,
2. a **secondary final table** with macroeconomic indicators (GDP, GINI, population) for European countries in the same comparable period,
3. a set of SQL scripts answering five research questions defined in the assignment.

## Final Output Tables
The following final tables are created in the database:

- `data_academy_content.t_alena_ulrichova_project_sql_primary_final`
- `data_academy_content.t_alena_ulrichova_project_sql_secondary_final`

> Note: Some scripts may need schema qualification adjustment depending on local DB setup.

## Repository Structure
- `sql/` – SQL scripts for exploration, staging views, final tables, and research-question analysis
- `docs/data_notes.md` – detailed data notes (data quality findings, assumptions, transformations, methodology notes, and analysis notes)
- `README.md` – project overview and execution guide

## SQL Files in This Repository

### Exploration
- `sql/01_explore_payroll.sql`  
  Initial payroll data exploration / diagnostics.

### Staging views
- `sql/02_staging_view_payroll.sql`  
  Creates staging view for yearly wage data (payroll).
- `sql/03_staging_view_prices.sql`  
  Creates staging view for yearly food prices with unit normalization.
- `sql/04_staging_view_common_years.sql`  
  Creates view with intersection of years available in wages and prices.

### Final tables
- `sql/t_alena_ulrichova_project_SQL_primary_final.sql`  
  Builds the primary final table for Czech wages + food prices (common years).
- `sql/t_alena_ulrichova_project_SQL_secondary_final.sql`  
  Builds the secondary final table for European macro indicators (GDP, GINI, population), aligned to common years.

### Research question queries
- `sql/11_q1_yoy_wage_trends.sql`  
  Q1: Are wages rising across all sectors over the years, or are they falling in some?
- `sql/12_q2_purchasing_power.sql`  
  Q2: How much milk and bread can be purchased for an average wage in the first and last comparable period?
- `sql/13_q3_yoy_price_difference.sql`  
  Q3: Which food category increases in price the slowest (lowest YoY percentage increase)?
- `sql/14_q4_prices_vs_wages_gap.sql`  
  Q4: Is there a year in which food prices increased significantly more than wages (more than 10 percentage points)?
- `sql/14a_q4_debug_prices_vs_wages_gap.sql`  
  Debug/support query for Q4 (step-by-step validation of yearly aggregates, YoY logic, and gap calculation).
- `sql/15_q5_gdp_effect.sql`  
  Q5: Does GDP growth relate to wage and food price changes in the same year or the following year?

## Recommended Execution Order (Rebuild)
If you want to rebuild the project outputs from scratch, run the scripts in this order:

### 1) Exploration / diagnostics (optional but useful)
1. `sql/01_explore_payroll.sql`

### 2) Staging views
2. `sql/02_staging_view_payroll.sql`
3. `sql/03_staging_view_prices.sql`
4. `sql/04_staging_view_common_years.sql`

### 3) Final tables
5. `sql/t_alena_ulrichova_project_SQL_primary_final.sql`
6. `sql/t_alena_ulrichova_project_SQL_secondary_final.sql`

### 4) Research questions
7. `sql/11_q1_yoy_wage_trends.sql`
8. `sql/12_q2_purchasing_power.sql`
9. `sql/13_q3_yoy_price_difference.sql`
10. `sql/14_q4_prices_vs_wages_gap.sql`
11. `sql/15_q5_gdp_effect.sql`

> `sql/14a_q4_debug_prices_vs_wages_gap.sql` is optional and was used to validate the Q4 logic when the final filtered query returned no rows.

## Documentation
Detailed methodology and data-quality notes are documented in:

- `docs/data_notes.md`

This includes:
- source tables used
- known anomalies (including payroll unit mismatch)
- transformation decisions
- staging logic
- notes for each research question
- interpretation caveats and limitations

## Notes / Assumptions
- Raw source tables were **not modified**.
- Data cleaning / interpretation fixes were handled in staging views and final-table logic.
- Results may support or refute the research questions depending on the observed data.
- A query returning no rows can be a valid analytical result (e.g., Q4 threshold condition not met), not necessarily a query error.

## Author
Alena Ulrichova