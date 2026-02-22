WITH pp AS (
  SELECT
    year,
    product_name,
    AVG(purchasable_units_per_avg_wage) AS units_per_avg_wage
  FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final
  WHERE product_name ILIKE '%mléko%' OR product_name ILIKE '%chléb%'
  GROUP BY year, product_name
),
bounds AS (
  SELECT MIN(year) AS first_year, MAX(year) AS last_year FROM pp
)
SELECT
  p.product_name,
  MAX(CASE WHEN p.year = b.first_year THEN ROUND(p.units_per_avg_wage::numeric, 2) END) AS first_year_units,
  MAX(CASE WHEN p.year = b.last_year  THEN ROUND(p.units_per_avg_wage::numeric, 2) END) AS last_year_units
FROM pp p
CROSS JOIN bounds b
GROUP BY p.product_name
ORDER BY p.product_name;
