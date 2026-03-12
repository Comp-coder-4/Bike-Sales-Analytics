USE DataWarehouseAnalytics;

/* Business Problem: How can we increase revenue? */

/* We've found that VIP customers bring the highest revenue concentration and average order value. 
Our target is to find where we can make effort to increase customer retention in order to increase revenue.

In this section of SQL, we find out the following:
	1. How many customers are leaving within 1yr of making their first order
	2. Whether there are any Regular customers that could potentially become VIP
	3. How sales from VIP customers is doing
*/
----------------------------------------------------------
----------------------------------------------------------
-- CTE's used in analysis

-- Customer behaviour
WITH CTE_customer_behaviour AS ( 
SELECT 
	c.customer_key,
	MIN(s.order_date) first_order,
	MAX(s.order_date) last_order,
	SUM(s.sales_amount) total_spending,
	DATEDIFF(month, MIN(s.order_date), MAX(s.order_date)) lifespan
	FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
	ON S.customer_key = c.customer_key
	GROUP BY c.customer_key  -- Here I use GROUP BY instead of window function. This avoids duplicate customer keys
)
-- Customer behaviour with customer segment
, CTE_customer_segments AS (
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
FROM CTE_customer_behaviour
) 
-- Customer behaviour with a column showing the date that is 1yr from each customer's first order
, CTE_customer_data_intermediate AS (
SELECT *, 
DATEADD(year, 1, first_order) first_order_plus_1year
FROM (
SELECT 
	s.customer_key,
	s.order_number,
	s.order_date,
	MIN(s.order_date) OVER(PARTITION BY s.customer_key) first_order,
	MAX(s.order_date) OVER(PARTITION BY s.customer_key) last_order,
	s.product_key,
	s.sales_amount,
	s.quantity
FROM gold.fact_sales s
	LEFT JOIN gold.dim_customers c
	ON S.customer_key = c.customer_key)t)

-- Final customer behaviour table with customer segment column and column showing the date 1yr from first order 
, CTE_customer_data AS (
SELECT i.*, 
s.customer_segment
FROM CTE_customer_data_intermediate i
LEFT JOIN CTE_customer_segments s
ON i.customer_key = s.customer_key)

-- Table with years and months from customer orders
, CTE_year_month AS (
SELECT 
DISTINCT YEAR(order_date) year, MONTH(order_date) month
FROM CTE_Customer_data
WHERE YEAR(order_date) IS NOT NULL)

-- This CTE looks at Regular customers. It creates a new column that checks whether their spending is near the VIP threshold (5000), in which case they are 'likely' to become a VIP. Otherwise they are 'unlikely' to become VIP.
, CTE_reg_likelihood AS (
SELECT *, 
CASE WHEN total_spend BETWEEN 4500 AND 5000
	THEN 'Likely'
	ELSE 'Unlikely'
	END AS become_VIP
FROM (
	SELECT *, SUM(sales_amount) OVER(PARTITION BY customer_key) total_spend 
	FROM CTE_customer_data
	WHERE customer_segment = 'Regular')t)

-- End of CTE's
----------------------------------------------------------
----------------------------------------------------------

----------------------------------------------------------
----------------------------------------------------------
-- Business focused questions

-- 1. How many customers did we lose within 1 year of their first purchase? What revenue did they bring?
-- 2. How many regular customers are nearly at the VIP threshold? VIP threshold = spending at least 5,000
-- 3. How is VIP sales performing? How do we retain VIP customers?

/* --------------------------------------------------------------------
----------------------------------------------------------------------
1. How many customers did we lose within 1 year of their first purchase? What revenue did they bring?
--------------------------------------------------------------------
----------------------------------------------------------------------*/
-- Customers lost within 1yr = 14,828
-- % lost = 14,828/ 18,484 = 80%
SELECT COUNT(distinct customer_key)
FROM (
	SELECT *
	FROM CTE_customer_data
	WHERE customer_key NOT IN (
	SELECT DISTINCT(CUSTOMER_KEY)
	FROM CTE_customer_data
	WHERE order_date >= first_order_plus_1year))t

-- Insight: A substantial amount of customers (80%) were lost within 1yr of their first purchase. 
-- Recommendation: Use 15-20% discount for older stock bikes and products on the first few orders with limited time offer to encourage repeat purchases. Focus on customers who have only made 1 order

-------------------

/* % revenue coming from customers who left within a year is
   (11794418/21431725) * 100 = 55% */

-- total revenue before from all customers within 1yr of first order
-- 21,431,725
SELECT SUM(sales_amount)
FROM CTE_customer_data
WHERE order_date < first_order_plus_1year

-- revenue from customers lost within 1yr of first order
-- 11,794,418
SELECT SUM(sales_amount)
FROM CTE_customer_data
WHERE customer_key NOT IN (
SELECT DISTINCT(CUSTOMER_KEY)
FROM CTE_customer_data
WHERE order_date >= first_order_plus_1year)


/* --------------------------------------------------------------------
----------------------------------------------------------------------
-- 2. How many regular customers are nearly at the VIP threshold? 
VIP threshold = spending at least 5,000
--------------------------------------------------------------------
----------------------------------------------------------------------*/

-- % of regular customers that are likely to become VIP
SELECT ROUND((SELECT CAST(COUNT(DISTINCT customer_key) AS FLOAT)
FROM CTE_reg_likelihood
WHERE become_VIP = 'Likely')/(SELECT CAST(COUNT(DISTINCT customer_key) AS FLOAT) 
FROM CTE_reg_likelihood) * 100, 1) percentage_regs_likely_to_become_VIP

-- Insight: 20% of regular customers are likely to become VIP 
-- Aim: To upsell Regular customers to VIP
-- Recommendation: Loyalty reward which offers 15-20% discount on an ugraded version of a bike the customer has already purchased. The business could do a family bundle deal for bikes to increase the order value and spending

---------------------------------------------------------------------

/* -------------------------------------------------------------------
----------------------------------------------------------------------
-- 3. How is VIP sales performing? How do we retain VIP customers?
---------------------------------------------------------------------
----------------------------------------------------------------------*/
 -- PROBLEM: In 2014, there were no orders made by VIP customers. For the subquery, I first did aggregations to get year, month, total_orders and total sales from CTE_customer_data using GROUP BY. However, SQL excluded 2014 from the results. 
 -- SOLUTION: To get results for all years (2010-2014) I made a CTE table of years and months of the customer orders, and with it I did a LEFT JOIN to the customer data CTE. This way, no year would be excluded from the results

-- 5 Month Moving Average
-- This query retrieves year, month, total orders, total sales, 5 month moving average for total orders and 5 month moving average for total sales
SELECT 
year,
month,
total_orders,
-- Orders Moving Average
AVG(total_orders) OVER(ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) moving_avg_orders,
total_sales,
AVG(total_sales) OVER(ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) moving_avg_sales
-- Sales Moving Average
FROM (
	SELECT  -- Subquery gets year, month, total_orders, total_sales for VIPs
	t.year, 
	t.month,
	COUNT(DISTINCT c.order_number) total_orders,
	CASE WHEN SUM(c.sales_amount) IS NULL THEN 0
		ELSE SUM(c.sales_amount) END total_sales
	FROM CTE_year_month t
	LEFT JOIN CTE_customer_data c
		ON t.year = YEAR(c.order_date)
		AND t.month = MONTH(c.order_date)
		AND c.customer_segment = 'VIP' -- filters
	GROUP BY t.year, t.month)t
WHERE year NOT IN (2010, 2014)
ORDER BY t.year, t.month

-- Aim: Retain VIP customers and keep sales high and steady as they were in 2013 into the new year
-- MICROSOFT EXCEL: Looking a the Year-on-Year VIP performance, sales were good in 2011, dropped in 2012 and increased again in 2013. Sales should be kept at the level it was in 2013. 
-- Recommendations: Looking at the Month-on-Month VIP performance, sales are highest during summer months. To ensure sales are kept this way, I recommend offering premium service including exclusive access to new bikes and fast delivery option