

--Step 1 Creating database and importing the csv file
create database SalesDB;

use SalesDB;

select * from sales;

--step 2 Data cleaning

--1 checking for how many rows imported

SELECT COUNT(*) as total_rows FROM sales;

--2 checking for duplicates

SELECT transaction_id,COUNT(*) as duplicates_count
FROM sales 
GROUP BY transaction_id
HAVING COUNT(transaction_id) >1

-- delete the duplicate rows

WITH CTE AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM sales
)
DELETE FROM CTE
WHERE Row_Num=2
SELECT * FROM CTE
WHERE transaction_id IN ('TXN240646','TXN342128','TXN855235','TXN981773')

--3 change the coumn names if needed or if any spel mistakes

EXEC sp_rename'sales.quantiy','quantity','COLUMN'

EXEC sp_rename'sales.prce','price','COLUMN'

select * from sales;

--4 check for datatypes
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales';

--5 Check for nullvalues

SELECT 
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS null_transaction_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS null_customer_name,
    SUM(CASE WHEN customer_age IS NULL THEN 1 ELSE 0 END) AS null_customer_age,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS null_product_name,
    SUM(CASE WHEN product_category IS NULL THEN 1 ELSE 0 END) AS null_product_category,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN payment_mode IS NULL THEN 1 ELSE 0 END) AS null_payment_mode,
    SUM(CASE WHEN purchase_date IS NULL THEN 1 ELSE 0 END) AS null_purchase_date,
    SUM(CASE WHEN time_of_purchase IS NULL THEN 1 ELSE 0 END) AS null_time_of_purchase,
    SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) AS null_status
FROM sales;

-- Handling null values

SELECT *
FROM sales 
WHERE transaction_id IS NULL
OR
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR
gender IS NULL
OR
product_id IS NULL
OR
product_name IS NULL
OR
product_category IS NULL
OR
quantity IS NULL
or
payment_mode is null
or
purchase_date is null
or 
status is null
or 
price is null

DELETE FROM sales 
WHERE  transaction_id IS NULL


SELECT * FROM sales 
Where Customer_name='Ehsaan Ram'

UPDATE sales
SET customer_id='CUST9494'
WHERE transaction_id='TXN977900'

SELECT * FROM sales 
Where Customer_name='Damini Raju'

UPDATE sales
SET customer_id='CUST1401'
WHERE transaction_id='TXN985663'

SELECT * FROM sales 
Where Customer_id='CUST1003'

UPDATE sales
SET customer_name='Mahika Saini',customer_age=35,gender='Male'
WHERE transaction_id='TXN432798'

select * from sales;

--step 6 Formating handling

select distinct gender from sales; --F, Male, Female, M

UPDATE sales
SET gender='M'
WHERE gender='Male'

UPDATE sales
SET gender='F'
WHERE gender='Female'

SELECT DISTINCT payment_mode
FROM sales

UPDATE sales
SET payment_mode='Credit Card'
WHERE payment_mode='CC'

--------------------------------------------------------------------------------------------------
--Data Analysis 
-- solving business problems 

--1 total num of transcations

SELECT COUNT(*) AS total_transactions
FROM sales;

-- count unique products

SELECT COUNT(DISTINCT product_id) AS unique_products
FROM sales;

-- total quantity sold
SELECT SUM(quantity) AS total_quantity_sold
FROM sales;

-- avaerage customer age

SELECT AVG(customer_age) AS avg_age
FROM sales;

-- customer count b gender
SELECT gender, COUNT(*) AS gender_count
FROM sales
GROUP BY gender;

-- orders by payment mode

SELECT payment_mode, COUNT(*) AS order_count
FROM sales
GROUP BY payment_mode;

-- most frequently ordered products
SELECT product_name, COUNT(*) AS order_count
FROM sales
GROUP BY product_name
ORDER BY order_count DESC;

-- total quantity sold per product

SELECT product_name, SUM(quantity) AS total_quantity
FROM sales
GROUP BY product_name
ORDER BY total_quantity DESC;

-- Daily transctions

SELECT purchase_date, COUNT(*) AS total_orders
FROM sales
GROUP BY purchase_date
ORDER BY purchase_date;

--top 10 questions for analysis

-- 1. What are the top 5 most selling products by quantity?

SELECT TOP 5 product_name, SUM(quantity) AS total_quantity_sold
FROM sales
WHERE status='delivered'
GROUP BY product_name
ORDER BY total_quantity_sold DESC

-- Business Impact / Solution:
-- Helps identify top 5 high-demand products.
-- Supports better inventory and stock management.
-- Avoids stockouts and improves customer satisfaction.
-- Helps focus promotions on best-selling items.
-- Improves sales forecasting and demand planning.

--?? 2. Which products are most frequently cancelled?

SELECT TOP 5 product_name, COUNT(*) AS total_cancelled
FROM sales
WHERE status='cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC

--Business Problem: Frequent cancellations affect revenue and customer trust.

-- Business Impact / Solution:
-- Helps identify products with high cancellation rates.
-- Business can check if the issue is quality, delivery, or pricing.
-- Can improve or replace the problematic products.
-- Helps reduce future cancellations and improve customer experience.


--?? 3. What time of the day has the highest number of purchases?

select * from sales
	
	SELECT 
		CASE 
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END AS time_of_day,
		COUNT(*) AS total_orders
	FROM sales
	GROUP BY 
		CASE 
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END
ORDER BY total_orders DESC
---------------------------------------------------------------------------------------------
SELECT 
	DATEPART(HOUR,time_of_purchase) AS Peak_time,
	COUNT(*) AS Total_orders
FROM sales
GROUP BY DATEPART(HOUR,time_of_purchase)
ORDER BY Peak_time

--Business Problem : Find peak sales times.

-- Business Solution:Knowing the peak purchase time helps the business plan better by increasing staff during busy hours, preparing enough inventory, and running targeted promotions when customers are most active. This improves customer service, reduces wait times, avoids stockouts, and can increase overall sales and operational efficiency.

--?? 4. Who are the top 5 highest spending customers?

SELECT * FROM sales

SELECT TOP 5 
    customer_name,
    FORMAT(SUM(CAST(price AS DECIMAL(18,2)) * CAST(quantity AS DECIMAL(18,2))), 
           'C0', 'en-IN') AS total_spend
FROM sales
GROUP BY customer_name
ORDER BY SUM(CAST(price AS DECIMAL(18,2)) * CAST(quantity AS DECIMAL(18,2))) DESC;


--Business Problem Solved: Identify VIP customers.

--Business Impact: Personalized offers, loyalty rewards, and retention.
-- Identifying the top spending customers helps the business understand who its VIP customers are. This allows the company to give them special offers, loyalty rewards, and personalized services to keep them engaged and retain them for the long term, which increases repeat sales and overall revenue.

--??? 5. Which product categories generate the highest revenue?

SELECT * FROM sales

SELECT 
    product_category,
    FORMAT(SUM(CAST(price AS DECIMAL(18,2)) * CAST(quantity AS DECIMAL(18,2))), 
           'C0','en-IN') AS Revenue
FROM sales
GROUP BY product_category
ORDER BY SUM(CAST(price AS DECIMAL(18,2)) * CAST(quantity AS DECIMAL(18,2))) DESC;


--Business Problem Solved: Identify top-performing product categories.

--Business Impact: Refine product strategy, supply chain, and promotions.
--allowing the business to invest more in high-margin or high-demand categories.

--?? 6. What is the return/cancellation rate per product category?

SELECT * FROM sales
--cancellation
SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='cancelled' THEN 1 END)*100.0/COUNT(*),'N3')+' %' AS cancelled_percent
FROM sales 
GROUP BY product_category
ORDER BY cancelled_percent DESC

--Return
SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='returned' THEN 1 END)*100.0/COUNT(*),'N3')+' %' AS returned_percent
FROM sales 
GROUP BY product_category
ORDER BY returned_percent DESC

--Business Problem Solved: Monitor dissatisfaction trends per category.


---Business Impact: Reduce returns, improve product descriptions/expectations.
--Helps identify and fix product or logistics issues.


--?? 7. What is the most preferred payment mode?

SELECT * FROM sales

SELECT payment_mode, COUNT(payment_mode) AS total_count
FROM sales 
GROUP BY payment_mode
ORDER BY total_count desc


--Business Problem Solved: Know which payment options customers prefer.

--Business Impact: Streamline payment processing, prioritize popular modes.

--?? 8. How does age group affect purchasing behavior?

SELECT * FROM sales
--SELECT MIN(customer_age) ,MAX(customer_age)
--from sales

SELECT 
    CASE    
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END AS age_group,
    FORMAT(
        SUM(CAST(price AS DECIMAL(18,2)) * CAST(quantity AS DECIMAL(18,2))),
        'C0','en-IN'
    ) AS total_purchase
FROM sales
GROUP BY 
    CASE    
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END
ORDER BY 
    SUM(CAST(price AS DECIMAL(18,2)) * CAST(quantity AS DECIMAL(18,2))) DESC;


--Business Problem Solved: Understand customer demographics.

--Business Impact: Targeted marketing and product recommendations by age group.


--?? 10. Are certain genders buying more specific product categories?

SELECT * from sales

--Method 1
SELECT gender,product_category,COUNT(product_category) AS total_purchase
FROM sales
GROUP BY gender,product_category
ORDER BY gender

--Method 2
SELECT * 
FROM ( 
	SELECT gender,product_category
	FROM sales 
	) AS source_table
PIVOT (
	COUNT(gender)
	FOR gender IN ([Male],[Female])
	) AS pivot_table
ORDER BY product_category

--Business Problem Solved: Gender-based product preferences.

--Business Impact: Personalized ads, gender-focused campaigns.
