-- Top 5 products generating highest revenue
SELECT TOP 5 p.product_name, SUM(s.sales_amount) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

-- 5 Worst performing products by sales
SELECT TOP 5 p.product_name, SUM(s.sales_amount) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC

-- Find top 10 customers with highest revenue and the 3 customers with fewest orders placed
SELECT TOP 10 c.customer_key, c.first_name, c.last_name, SUM(s.sales_amount) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON c.customer_key = s.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC

SELECT TOP 3 c.customer_key, c.first_name, c.last_name, COUNT(DISTINCT(ORDER_NUMBER)) total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON c.customer_key = s.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders ASC
