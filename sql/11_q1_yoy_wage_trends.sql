WITH w AS (
	SELECT
		year,
		industry_name,
		AVG(avg_wage_czk) AS wage
	FROM data_academy_content.t_alena_ulrichova_project_sql_primary_final 
	GROUP BY year, industry_name
)
SELECT
	industry_name,
	year,
	wage,
	ROUND((wage/LAG(wage) OVER (PARTITION BY industry_name ORDER BY year) - 1)::NUMERIC, 4) AS yoy_wage_growth
FROM w
ORDER BY industry_name, year;
