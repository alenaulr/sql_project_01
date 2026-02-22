WITH cz_aff AS (
  SELECT
    year,
    AVG(avg_wage_czk)           AS wage,
    AVG(avg_price_per_unit_czk) AS price
  FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final
  GROUP BY year
),
cz_macro AS (
  SELECT
    year,
    gdp, gini, population
  FROM data_academy_content.t_alena_ulrichova_project_sql_secondary_final
  WHERE country_name = 'Czech Republic'
),
base AS (
  SELECT
    a.year,
    (a.wage  / LAG(a.wage)  OVER (ORDER BY a.year) - 1) AS yoy_wage,
    (a.price / LAG(a.price) OVER (ORDER BY a.year) - 1) AS yoy_price,
    (m.gdp   / LAG(m.gdp)   OVER (ORDER BY m.year) - 1) AS yoy_gdp,
    m.gini,
    m.population
  FROM cz_aff a
  JOIN cz_macro m ON m.year = a.year
)
SELECT
  year,
  ROUND(yoy_wage::numeric, 4) AS yoy_wage,
  ROUND(yoy_price::numeric, 4) AS yoy_price,
  ROUND(yoy_gdp::numeric, 4) AS yoy_gdp,
  ROUND(LEAD(yoy_wage)  OVER (ORDER BY year)::numeric, 4) AS yoy_wage_next_year,
  ROUND(LEAD(yoy_price) OVER (ORDER BY year)::numeric, 4) AS yoy_price_next_year,
  gini,
  population
FROM base
ORDER BY year;