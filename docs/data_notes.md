# Data Notes – sql_project_01 Food Accessibility

Last updated: 2026-01-17  
Author: Alena Ulrichova

## 1) Purpose
This document records data quality findings, assumptions, filters, and transformations so the analysis is reproducible and auditable.

## 2) Data Sources
- `czechia_payroll` + reference tables:
  - `czechia_payroll_industry_branch` (industry),
  - `czechia_payroll_unit` (units),
  - `czechia_payroll_value_type` (metrics),
  - `czechia_payroll_calculation` (calculation method).
- `czechia_price` + `czechia_price_category` (food prices).
- Additional: `economies`, `countries` (EU metrics: GDP, GINI, population).

## 3) Known Issues / Anomalies

### 3.1 Swapped units in `czechia_payroll`
While inspecting `value_type_code × unit_code` combinations, I observed:

- `value_type_code = 5958` = “Průměrná hrubá mzda na zaměstnance” (Average gross wage per employee)  
  appears in the raw data with `unit_code = 200` = “tis. osob (thousands of persons)” expected: CZK

- `value_type_code = 316` = “Průměrný počet zaměstnaných osob” (Average number of employed persons)  
  appears with `unit_code = 80403` = “Kč (CZK)” expected: thousands of persons

Interpretation: In this dataset dump, the unit codes for the two primary metrics appear swapped. The values themselves look plausible (wages in thousands/tens of thousands CZK; employment in thousands of persons), but the attached `unit_code` is inconsistent.

Decision: I did not modify raw data. Instead, I fixed the interpretation in staging views by deriving the unit logically from `value_type_code` (wages → CZK, employment → thousands of persons).

Diagnostic query (repro):
```sql
SELECT 
  vt.code AS vt_code, vt.name AS value_type,
  u.code  AS unit_code, u.name AS unit_name,
  COUNT(*) AS rows,
  MIN(p.value) AS min_v, MAX(p.value) AS max_v
FROM czechia_payroll p
JOIN czechia_payroll_value_type vt ON vt.code = p.value_type_code
JOIN czechia_payroll_unit       u  ON u.code  = p.unit_code
GROUP BY 1,2,3,4
ORDER BY 1,3;
```

## 4) Transformations & Staging (recap)

### 4.1 Wages (staging)
`v_payroll_wage_yearly` — yearly average gross wage per employee (CZK), by industry.  
Filter by `value_type_code = 5958`. Aggregated to `year × industry`.

### 4.2 Prices (staging)
`v_prices_yearly` — yearly average **standardized** price per product:
- Normalize per-unit:
  - `g`→`kg` and `ml`→`l` via 1000 multiplier,
  - else use provided unit and `price_value` as divisor.
- Grain: `year × product`.

### 4.3 Common years
`v_common_years` — intersection of years present in both staging views.
**Schema:** 'data_academy_content' (adjust if different in your DB).

### 4.4 Primary final (CZ)
**Name:** `data_academy_content.t_alena_ulrichova_project_sql_primary_final`  
**Grain:** 1 row = `industry × product × year` (CZ only, common years)  
**Columns (key):** `year, industry_code, industry_name, avg_wage_czk, product_name, unit_std, avg_price_per_unit_czk, purchasable_units_per_avg_wage`  
**Note:** `purchasable_units_per_avg_wage = avg_wage_czk / avg_price_per_unit_czk` (safety via `NULLIF`).


---

## 5) Secondary Final (Europe macro indicators)

**Name:** `data_academy_content.t_alena_ulrichova_project_sql_secondary_final`  
**Grain:** 1 row = `country × year`  
**Coverage:** `countries.continent = 'Europe'` and `year = v_common_years`  
**Columns:** `year, country_name, country_code, gdp, gini, population`
**Country code:** `iso_numeric` from `countries` (aliased to `country_code`).

### 5.1 Source tables
- `data_academy_content.economies` (`year, country, gdp, gini, population`)
- `data_academy_content.countries` (`country, iso_numeric, continent`)

### 5.2 Join strategy
- Normalize names on both sides with `UPPER(TRIM(...))`.
- Inner join `economies` ↔ `countries` on normalized name.
- Aggregates/regions present in `economies.country` (r.g. "European Union," "Small states") are **excluded automatically** by the join (no matching row in `countries`).

### 5.3 Decisions
- Years: aligned to v_common_years (consistent with the primary final table)
- Scope: Europe only via countries.continent
- Czech Republic: included
- No raw-data edits: cleaning handled in CTAS

**Repro (simplified CTAS):**
```sql
DROP TABLE IF EXISTS data_academy_content.t_alena_ulrichova_project_SQL_secondary_final;

CREATE TABLE data_academy_content.t_alena_ulrichova_project_SQL_secondary_final AS
WITH e AS (
  SELECT year,
         UPPER(TRIM(country)) AS e_country_norm,
         gdp, gini, population
  FROM data_academy_content.economies
),
c AS (
  SELECT UPPER(TRIM(country)) AS c_country_norm,
         country              AS country_name,
         iso_numeric          AS country_code,
         continent
  FROM data_academy_content.countries
)
SELECT e.year, c.country_name, c.country_code, e.gdp, e.gini, e.population
FROM e
JOIN c ON c.c_country_norm = e.e_country_norm
WHERE c.continent = 'Europe'
  AND e.year IN (SELECT year FROM data_academy_content.v_common_years);  -- adjust schema if needed
