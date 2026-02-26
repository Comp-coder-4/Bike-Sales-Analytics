USE DataWarehouseAnalytics

-- Measures Exploration
-- Calculate high level aggregations (key metrics)

-- Total Sales
SELECT SUM(sales_amount) total_sales FROM gold.fact_sales
-- How many items are sold
SELECT SUM(quantity) total_items_sold
FROM gold.fact_sales
-- Average selling price
SELECT AVG(price) avg_selling_price
FROM (SELECT DISTINCT product_key, price 
FROM gold.fact_sales)t
--Total number of orders
SELECT COUNT(DISTINCT order_number) total_orders
FROM gold.fact_sales
-- Total number of products
SELECT COUNT(DISTINCT product_id)
FROM gold.dim_products
-- Total number of customers
SELECT COUNT(DISTINCT(CUSTOMER_ID)) total_customers
FROM gold.dim_customers;
-- Total number of customers that have placed an order
SELECT COUNT(DISTINCT customer_key)
FROM gold.fact_sales

-- Make report that shows all key metrics of business
SELECT 'Total Sales' measure_name, SUM(sales_amount) measure_value FROM gold.fact_sales

UNION ALL

SELECT 'Total Items Sold' measure_name, SUM(quantity) measure_value
FROM gold.fact_sales

UNION ALL

SELECT 'Avg Selling Price' measure_name, AVG(price) measure_value
FROM (SELECT DISTINCT product_key, price 
FROM gold.fact_sales)t

UNION ALL

SELECT 'Total Orders' measure_name, COUNT(DISTINCT order_number) measure_value
FROM gold.fact_sales

UNION ALL

SELECT 'Total Products' measure_name,COUNT(DISTINCT product_id) measure_value
FROM gold.dim_products

UNION ALL

SELECT 'Total customers' measure_name, COUNT(DISTINCT(CUSTOMER_ID)) measure_value
FROM gold.dim_customers

UNION ALL

SELECT 'Total Customers With Orders' measure_name, COUNT(DISTINCT customer_key) measure_value
FROM gold.fact_sales