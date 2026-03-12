USE DataWarehouseAnalytics

-- which categories contribute most to overall sales?

-- Total sales by category
WITH CTE_Category_Sales AS (
	SELECT 
	SUM(s.sales_amount) SalesByCategory,
	p.category
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
	GROUP BY p.category
)
-- Total sales from all categories
, CTE_Total_Category_Sales AS (
	SELECT SUM(SalesByCategory) total_sales
	FROM CTE_Category_Sales
)

-- proportion of sales by category to whole
SELECT 
SalesByCategory,
category,
CONCAT(ROUND((CAST(SalesByCategory AS FLOAT)/CAST((SELECT * FROM CTE_Total_Category_Sales) AS FLOAT)), 3) * 100, '%') sales_proportion_to_whole
FROM CTE_Category_Sales
ORDER BY SalesByCategory DESC


-- total sales of all categories (for my checking) :)
SELECT SUM(salesBYCATEGORY) FROM CTE_Category_Sales -- 29356250

