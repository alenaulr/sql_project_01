SELECT COUNT(*) AS cnt
FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final;

SELECT
  MIN(year) AS min_year,
  MAX(year) AS max_year,
  COUNT(DISTINCT year) AS distinct_years
FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final;

WITH w AS (
  SELECT year, AVG(avg_wage_czk) AS wage
  FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final
  GROUP BY year
)
SELECT *
FROM w
ORDER BY year;

WITH p AS (
  SELECT year, AVG(avg_price_per_unit_czk) AS price
  FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final
  GROUP BY year
)
SELECT *
FROM p
ORDER BY year;

WITH w AS (
  SELECT year, AVG(avg_wage_czk) AS wage
  FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final
  GROUP BY year
),
p AS (
  SELECT year, AVG(avg_price_per_unit_czk) AS price
  FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final
  GROUP BY year
)
SELECT
  w.year,
  w.wage,
  p.price
FROM w
JOIN p USING (year)
ORDER BY w.year;

WITH w AS (
  SELECT year, AVG(avg_wage_czk) AS wage
  FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final
  GROUP BY year
),
p AS (
  SELECT year, AVG(avg_price_per_unit_czk) AS price
  FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final
  GROUP BY year
),
g AS (
  SELECT
    w.year,
    w.wage,
    p.price,
    LAG(w.wage)  OVER (ORDER BY w.year) AS prev_wage,
    LAG(p.price) OVER (ORDER BY p.year) AS prev_price,
    (w.wage  / LAG(w.wage)  OVER (ORDER BY w.year) - 1) AS yoy_wage,
    (p.price / LAG(p.price) OVER (ORDER BY p.year) - 1) AS yoy_price
  FROM w
  JOIN p USING (year)
)
SELECT *
FROM g
ORDER BY year;