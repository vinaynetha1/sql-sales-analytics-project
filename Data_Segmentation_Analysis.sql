WITH product_segments AS 
( 
SELECT product_key,
product_name, 
cost,
CASE 
	WHEN cost < 100 THEN 'ABOVE 100'
	WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	ELSE 'ABOVE 1000'
END cost_range FROM dbo.[gold.dim_products] ) 

SELECT cost_range,
COUNT(product_key) as total_products
FROM product_segments 
GROUP BY cost_range 
ORDER BY cost_range;

WITH lifespan_segments AS
( 
SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) as first_order, 
MAX(order_date) as last_order, 
DATEDIFF(month, MIN(order_date), 
MAX(order_date)) as Life_span
FROM dbo.[gold.fact_sales] f 
LEFT JOIN dbo.[gold.dim_customers] c 
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT customer_segment, 
COUNT(customer_key) as total_customers 
FROM ( 
Select customer_key,
total_spending, Life_span, 
CASE 
	WHEN Life_span >= 12 AND total_spending > 5000 THEN 'VIP' 
	WHEN Life_span >=12 AND total_spending <= 5000 THEN 'REGULAR' 
	ELSE 'NEW' 
END customer_segment FROM lifespan_segments 
	) t 
GROUP BY customer_segment;