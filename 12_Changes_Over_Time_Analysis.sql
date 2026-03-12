USE DataWarehouseAnalytics


SELECT 
YEAR(order_date) order_year, 
MONTH(order_date) order_month,
SUM(SALES_AMOUNT) Total_Sales
FROM gold.fact_sales
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)

