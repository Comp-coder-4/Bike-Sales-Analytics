USE DataWarehouseAnalytics

/* Segment products into cost ranges and count how many products fall into each segment */
WITH CTE_cost_segments AS (
	SELECT 
	product_key,
	product_name,
	category,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100 to 500'
		WHEN cost BETWEEN 500 AND 900 THEN '500 to 900'
		ELSE 'Above 900'
		END AS cost_segment
	FROM gold.dim_products
)

SELECT 
cost_segment,
COUNT(product_name) products
FROM CTE_cost_segments
GROUP BY cost_segment
ORDER BY products DESC


/* Group customers into 3 segments based on their spending behaviour:
	1. VIP: Customers with at least 12 months of history and spending more than 5,000
	2. Regular: Customers with at least 12 months of history but spending 5,000 or less
	3. New: Customers with a lifespan less than 12 months

	Find total number of customers by each group! :) */

-- customer history
SELECT 
s.order_number,
s.customer_key,
s.order_date,
c.first_name,
c.last_name,
MIN(s.order_date) OVER(PARTITION BY s.customer_key) first_order,
MAX(s.order_date) OVER(PARTITION BY s.customer_key) last_order,
DATEDIFF(month, MIN(s.order_date) OVER(PARTITION BY s.customer_key), MAX(s.order_date) OVER(PARTITION BY s.customer_key)) order_history_months
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON S.customer_key = c.customer_key
ORDER BY customer_key, first_name, last_name

-- adding sales to above query (customer history) to get complete customer behaviour
SELECT 
	s.order_number,
	s.sales_amount,
	s.customer_key,
	s.order_date,
	c.first_name,
	c.last_name,
	MIN(s.order_date) OVER(PARTITION BY s.customer_key) first_order,
	MAX(s.order_date) OVER(PARTITION BY s.customer_key) last_order,
	DATEDIFF(month, MIN(s.order_date) OVER(PARTITION BY s.customer_key), MAX(s.order_date) OVER(PARTITION BY s.customer_key)) order_history_months,
	SUM(s.sales_amount) OVER(PARTITION BY s.customer_key) total_sales_by_customer
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
	ON S.customer_key = c.customer_key
	ORDER BY customer_key, first_name, last_name

-- making CTE from previous query
WITH CTE_customer_behaviour AS (
	SELECT 
	s.order_number,
	s.sales_amount,
	s.customer_key,
	s.order_date,
	c.first_name,
	c.last_name,
	MIN(s.order_date) OVER(PARTITION BY s.customer_key) first_order,
	MAX(s.order_date) OVER(PARTITION BY s.customer_key) last_order,
	DATEDIFF(month, MIN(s.order_date) OVER(PARTITION BY s.customer_key), MAX(s.order_date) OVER(PARTITION BY s.customer_key)) order_history_months,
	SUM(s.sales_amount) OVER(PARTITION BY s.customer_key) total_spending
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
	ON S.customer_key = c.customer_key
)
, CTE_customer_segments AS (
	SELECT 
	customer_key,
	first_name,
	last_name, 
	order_history_months,
	total_spending,
	CASE WHEN order_history_months >= 12 AND total_spending > 5000
		THEN 'VIP'
		WHEN order_history_months >= 12 AND total_spending <= 5000
		THEN 'Regular'
		WHEN order_history_months < 12
		THEN 'New'
		WHEN order_date IS NULL
		THEN 'unknown'
		END AS customer_segment
	FROM CTE_customer_behaviour
)

-- Number of customers per segment
SELECT 
customer_segment,
COUNT(DISTINCT customer_key) customers  -- Need distinct because we have repeating rows for customer_key! :D
FROM CTE_Customer_segments
WHERE customer_segment != 'unknown'
GROUP BY customer_segment
ORDER BY customers DESC



-- SECOND TRY

/* Group customers into 3 segments based on their spending behaviour:
	1. VIP: Customers with at least 12 months of history and spending more than 5,000
	2. Regular: Customers with at least 12 months of history but spending 5,000 or less
	3. New: Customers with a lifespan less than 12 months

	Find total number of customers by each group! :) */

WITH CTE_customer_behaviour2 AS (
SELECT 
	c.customer_key,
	MIN(s.order_date) first_order,
	MAX(s.order_date) last_order,
	SUM(s.sales_amount) total_spending,
	DATEDIFF(month, MIN(s.order_date), MAX(s.order_date)) lifespan
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
	ON S.customer_key = c.customer_key
	GROUP BY c.customer_key
)
, CTE_customer_segments2 AS (
SELECT 
customer_key,
lifespan,
total_spending,
CASE WHEN lifespan >= 12 AND total_spending > 5000
	THEN 'VIP'
	WHEN lifespan >= 12 AND total_spending <= 5000
	THEN 'Regular'
	ELSE 'New'
	END AS customer_segment
FROM CTE_customer_behaviour2
)

SELECT 
customer_segment,
COUNT(customer_key) customers
FROM CTE_customer_segments2
GROUP BY customer_segment
ORDER BY customers DESC