/* 
================================================================
Customer Report
================================================================
Purpose:
	- This report consolidates key customer metrics and behaviours
	
Highlights:
	1. Gathers essential fields such as names, ages, and transaction details
	2. Segments customers into categories (VIP, regular, New) and age groups
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend
=================================================================
*/

CREATE VIEW gold.report_customers AS
WITH CTE_base_query AS (
/*-----------------------------------------------------------------
1) Base Query: Retrieve core columns from tables
------------------------------------------------------------------*/
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) customer_name,
DATEDIFF(year, c.birthdate, GETDATE()) age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key	
WHERE order_date IS NOT NULL
)

/*-----------------------------------------------------------------
2) Aggregate Query: Customer level Aggregations 
------------------------------------------------------------------*/
, CTE_customers_aggregations AS (
	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) total_orders,
		SUM(sales_amount) total_sales,
		SUM(quantity) total_quantity,
		COUNT(DISTINCT product_key) total_products,
		MAX(order_date) last_order,
		DATEDIFF(month, MIN(order_date), MAX(order_date)) lifespan
	FROM CTE_base_query
	GROUP BY customer_key,
		customer_number,
		customer_name,
		age
)

/*-----------------------------------------------------------------
3) Customer Segments and KPIs Query:
-------------------------------------------------------------------*/
SELECT 
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
	WHEN age BETWEEN 20 AND 29 THEN '20-29'
	WHEN age BETWEEN 30 AND 39 THEN '30-39'
	WHEN age BETWEEN 40 AND 49 THEN '40-49'
	ELSE '50 and above'
	END AS age_group,
CASE WHEN lifespan >= 12 AND total_sales > 5000
	THEN 'VIP'
	WHEN lifespan >= 12 AND total_sales <= 5000
	THEN 'Regular'
	WHEN lifespan < 12 -- TRY ELSE 'NEW'!
	THEN 'New'
	END AS customer_segment,
total_orders,
total_sales,
total_quantity,
total_products,
DATEDIFF(month, last_order, GETDATE()) recency,

-- Average Order Value (AVO)
CASE WHEN total_orders = 0 THEN 0  -- make sure we don't divide by 0
	ELSE total_sales/total_orders
	END avg_order_value,

-- Average Monthly Spend
CASE WHEN lifespan = 0 THEN total_sales 
	ELSE total_sales/lifespan
	END avg_monthly_spend

FROM CTE_customers_aggregations