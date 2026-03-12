/*
============================================
Product Report
============================================
Purpose:
	- This report shows key product metrics and behaviours

Highlights:
	1. Gathers fields inlcuding product name, category, subcategory, cost
	2. Segments products by revenue to identify High-Performers, Mid-Range and Low-Performers
	3. Aggregates product level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (months)
	4. Calculates KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
============================================
*/

CREATE VIEW gold.report_products AS 
WITH CTE_base AS (
/*-----------------------------------------------------------------
1) Base Query: Retrieve core columns from tables
------------------------------------------------------------------*/
	SELECT 
	p.product_key,
	p.product_name, 
	p.category, 
	p.subcategory, 
	p.cost,
	f.order_number,
	f.customer_key,
	f.order_date,
	f.sales_amount,
	f.quantity
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL -- remember valid sales dates
)

/*-----------------------------------------------------------------
2) Aggregate Query: Product level Aggregations 

------------------------------------------------------------------*/
, CTE_product_aggregation AS (
	SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	COUNT(DISTINCT order_number) total_orders,
	MAX(order_date) last_order,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) lifespan,
	COUNT(DISTINCT customer_key) total_customers,
	SUM(sales_amount) total_sales,
	SUM(quantity) total_quantity,

	-- avg selling price
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)) , 1) avg_selling_price -- If quantity is 0, replace with NULL to avoid dividing by 0
	FROM CTE_base
	GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

/*-----------------------------------------------------------------
3) Product Segments and KPIs Query:
-------------------------------------------------------------------*/
SELECT 
product_key,
product_name,
category,
subcategory,
cost,
avg_selling_price,
total_orders,
total_sales,
CASE WHEN total_sales < 10000 THEN 'Low-Performer'
	WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid-Range'
	WHEN total_sales > 50000 THEN 'High-Performer'
	END AS product_segment,
total_quantity,
total_customers,
lifespan,
DATEDIFF(month, last_order, GETDATE()) recency,

-- Average Order Revenue (AOR)
CASE WHEN total_orders = 0 THEN 0
	ELSE total_sales/total_orders
	END avg_order_revenue,

-- Average Monthly Revenue
CASE WHEN lifespan = 0 THEN lifespan
	ELSE total_sales / lifespan
	END avg_monthly_revenue

FROM CTE_product_aggregation