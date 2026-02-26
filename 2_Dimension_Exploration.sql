-- Look at unique values in dimensions

-- Customers
SELECT *
FROM gold.dim_customers

/* Dimensions
country
marital status
gender */

SELECT DISTINCT(COUNTRY) FROM GOLD.dim_customers
SELECT DISTINCT(marital_status) FROM GOLD.dim_customers
SELECT DISTINCT(gender) FROM GOLD.dim_customers 

-- Products
SELECT * FROM GOLD.DIM_PRODUCTS
/* Dimensions
product_name,
category
subcategory
start_date */

SELECT DISTINCT product_name FROM gold.dim_products
