# Bike Sales Analytics: Customer Segmentation Analysis

The dataset looks at bike and other bike-related product sales, along with customer data and product data.

## Business Problem: How can we increase revenue?

The goal was to identify customer segments and retention strategies to increase revenue.
I grouped customers into 3 segments based on their spending behaviour:
	1. VIP: Customers with at least 12 months of history and spending more than 5,000
	2. Regular: Customers with at least 12 months of history but spending 5,000 or less
	3. New: Customers with a lifespan less than 12 months

## Steps:
  1. Exploratory Data Analysis (ED)
  2. Customer Segmentation Analysis
  3. Customer Retention Analysis
     
Tools used: SQL, Excel

## Key Insights & Recommendations
1. Insight: 20% of Regular customers are near the VIP threshold. Recommendation: Loyalty reward which offers 15-20% discount on an ugraded version of a bike the customer has already purchased. The business could do a family bundle deal for bikes to increase the order value and spending
2. Insight: Looking at the Month-on-Month VIP performance, sales are highest during summer months. Recommendation: To ensure sales are kept this way, I recommend offering premium service including exclusive access to new bikes and fast delivery option

## File Structure
Exploratory Data Analysis SQL files are numbered from 01 to 05 and are labelled with 'EDA'. For example, 01_EDA_Database_Exploration.
Customer Segmentation Analysis is the file numbered 06.
Customer Retention Analysis is files numbered 07 and 08.

There is also a Customer Report and Product Report in which I created 2 views
___________
This project is a combination of what I completed as part of Udemy's "SQL Mastery for Data Analytics and Business Intelligence" course and my own ideas. I gave the project a business problem and business context.
