-- Find total sales per month & running total of sales over time

SELECT 
MONTH(order_date) order_month,
DATENAME(month, order_date) order_monthname,
SUM(sales_amount) total_sales
FROM gold.fact_sales
WHERE MONTH(order_date) IS NOT NULL
GROUP BY MONTH(order_date), DATENAME(month, order_date) 
ORDER BY MONTH(order_date)

-- running total
SELECT *,
SUM(total_sales) OVER(ORDER BY order_date) running_total_sales
FROM (
SELECT 
DATETRUNC(month, order_date) order_date,
SUM(sales_amount) total_sales
FROM gold.fact_sales
WHERE DATETRUNC(month, order_date) IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t


-- running total, partitioned by year
SELECT *,
SUM(total_sales) OVER(PARTITION BY DATETRUNC(year, order_date) ORDER BY order_date) running_total_sales
FROM (
SELECT 
DATETRUNC(month, order_date) order_date,
SUM(sales_amount) total_sales
FROM gold.fact_sales
WHERE DATETRUNC(month, order_date) IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t


-- you can also truncate by year...
SELECT *,
SUM(total_sales) OVER(ORDER BY order_date) running_total_sales
FROM (
SELECT 
DATETRUNC(year, order_date) order_date,
SUM(sales_amount) total_sales
FROM gold.fact_sales
WHERE DATETRUNC(year, order_date) IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
)t
