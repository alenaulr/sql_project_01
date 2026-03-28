DROP TABLE IF EXISTS data_academy_content.t_alena_ulrichova_project_SQL_primary_final;

CREATE TABLE data_academy_content.t_alena_ulrichova_project_SQL_primary_final AS
SELECT
	y.year,
	pw.industry_code,
	pw.industry_name,
	pw.avg_wage_czk,
 	pr.price_category_code,
	pr.product_name,
	pr.unit_std,
	pr.avg_price_per_unit_czk, 
	(pw.avg_wage_czk / NULLIF(pr.avg_price_per_unit_czk, 0)) AS purchasable_units_per_avg_wage
FROM data_academy_content.v_common_years y
JOIN data_academy_content.v_payroll_wage_yearly pw USING (year)
JOIN data_academy_content.v_prices_yearly pr USING (year);



