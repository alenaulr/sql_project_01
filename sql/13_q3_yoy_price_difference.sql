WITH price_y AS (
  SELECT
    year,
    product_name,
    AVG(avg_price_per_unit_czk) AS price
  FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final
  GROUP BY year, product_name
),
yoy AS (
  SELECT
    product_name,
    year,
    (price / LAG(price) OVER (PARTITION BY product_name ORDER BY year) - 1) AS yoy_price_growth
  FROM price_y
)
SELECT
  product_name,
  ROUND(AVG(yoy_price_growth)::numeric, 4) AS avg_yoy_growth
FROM yoy
WHERE yoy_price_growth IS NOT NULL
GROUP BY product_name
ORDER BY avg_yoy_growth ASC
LIMIT 10;