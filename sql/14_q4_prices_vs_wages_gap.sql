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
    (w.wage  / LAG(w.wage)  OVER (ORDER BY w.year) - 1) AS yoy_wage,
    (p.price / LAG(p.price) OVER (ORDER BY p.year) - 1) AS yoy_price
  FROM w JOIN p USING (year)
)
SELECT
  year,
  ROUND(yoy_price::numeric,4) AS yoy_price,
  ROUND(yoy_wage::numeric,4)  AS yoy_wage,
  ROUND((yoy_price - yoy_wage)::numeric,4) AS gap_price_minus_wage
FROM g
WHERE yoy_price IS NOT NULL AND yoy_wage IS NOT NULL
  AND (yoy_price - yoy_wage) > 0.10
ORDER BY year;