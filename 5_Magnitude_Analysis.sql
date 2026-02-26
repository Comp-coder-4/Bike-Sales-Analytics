-- Comparing measures by categories

-- Total customers by countries
SELECT country, COUNT(DISTINCT customer_id) customers
FROM gold.dim_customers
GROUP BY country
ORDER BY customers DESC

-- Total customers by gender
SELECT gender, COUNT(DISTINCT customer_id) customers
FROM gold.dim_customers
GROUP BY gender
order by customers DESC

-- Total products by category
SELECT category, COUNT(product_id) products
FROM gold.dim_products
GROUP BY category
ORDER BY products DESC

-- Avg costs in each category
SELECT category, AVG(cost) avg_cost
FROM Gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC

-- Total revenue for each category
-- START WITH FACT THEN LEFT JOIN DIMENSION
SELECT category, SUM(sales_amount) total_revenue
FROM (
	SELECT p.category, s.sales_amount
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_products p
	ON p.product_key = s.product_key
)t
GROUP BY category
ORDER BY total_revenue DESC


-- Total revenue by each customer
SELECT c.customer_key, CONCAT(c.first_name, ' ', c.last_name) customer_name, SUM(s.sales_amount) total_revenue
FROM gold.fact_sales s 
LEFT JOIN gold.dim_customers c
ON c.customer_key = s.customer_key
GROUP BY c.customer_key, CONCAT(c.first_name, ' ', c.last_name)
ORDER BY total_revenue DESC


-- Distribution of sold items across countries
SELECT SUM(s.quantity) total_items_sold, c.country
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_items_sold DESC