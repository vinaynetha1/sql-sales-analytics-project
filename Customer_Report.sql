
CREATE VIEW gold.report_customers AS
WITH base_query AS (
SELECT
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) as Customer_name,
	DATEDIFF(year, c.birthdate, GETDATE()) Age
FROM dbo.[gold.fact_sales] f
LEFT JOIN dbo.[gold.dim_customers] c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL

), 
customer_segmentation AS (

SELECT 
Customer_key,
customer_number,
Customer_name,
age,
COUNT(DISTINCT order_number) as total_orders,
SUM(sales_amount) as total_sales,
SUM(quantity) as total_quantity,
COUNT(DISTINCT Customer_number) as total_customers,
MAX(order_date) as last_order_date,
DATEDIFF(month, MIN(order_date), MAX(order_date)) as life_span
FROM base_query
GROUP BY
	Customer_key,
	customer_number,
	Customer_name,
	age
)

SELECT 
	Customer_key,
	customer_number,
	Customer_name,
	age,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
	life_span,
	CASE 
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		ELSE 'above 50'
	END as Age_group,
	CASE
		WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN life_span >=12 AND total_sales <= 5000 THEN 'REGULAR'
		ELSE 'NEW'
		END customer_segment,
		last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) as recency,
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END as avg_order_value,
	CASE 
		WHEN life_span = 0 THEN total_sales
		ELSE total_sales / life_span
	END avg_monthly_spend
FROM customer_segmentation

Select * FROM gold.report_customers