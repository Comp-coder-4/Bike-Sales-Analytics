-- Earliest and last order
-- Years of sales
SELECT MIN(order_date) earliest_order, MAX(order_date) latest_order, DATEDIFF(year, MIN(order_date), MAX(order_date)) years_of_sales
FROM gold.fact_sales

-- Age range of customers
SELECT
MIN(birthdate) earliest_birthdate, 
DATEDIFF(year, MIN(birthdate), GETDATE()) oldest_age,
MAX(birthdate) latest_birthdate,
DATEDIFF(year, MAX(birthdate), GETDATE()) youngest_age
FROM gold.dim_customers

