USE DataWarehouseAnalytics;

/* Analyse yearly performance of products by comparing their sales to both the avg sales performance of the product and the previous year's sales */

WITH CTE_yearly_product_sales AS (
	SELECT 
	YEAR(order_date) order_year,
	p.product_name, 
	SUM(s.sales_amount) current_sales
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
	ON p.product_key = s.product_key
	WHERE YEAR(order_date) IS NOT NULL 
	GROUP BY YEAR(order_date), p.product_name
)

SELECT 
order_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) diff_avg, -- difference between current sales and avg sales
CASE WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above Avg'
     WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below Avg'
	 ELSE 'Avg' 
	 END AS Flag,
	 -- Year Over Year analysis
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) previous_year_sales,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) diff_previous,
CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'Increase'
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'Decrease'
	ELSE 'Same'
	END AS Previous_Year_Flag
FROM CTE_yearly_product_sales
ORDER BY product_name, order_year



-- Comparing with previous years FIRST ATTEMPT
WITH CTE_yearly_product_sales AS (
	SELECT 
	YEAR(order_date) order_year,
	p.product_name, 
	SUM(s.sales_amount) current_sales
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
	ON p.product_key = s.product_key
	WHERE YEAR(order_date) IS NOT NULL 
	GROUP BY YEAR(order_date), p.product_name
)

SELECT 
order_year,
product_name,
current_sales, 
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) previous_year_sales,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) diff_previous,
CASE WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) > 0 THEN 'Above last year'
	WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year ASC) < 0 THEN 'Below last year'
	ELSE 'Same'
	END AS Flag
FROM CTE_yearly_product_sales
