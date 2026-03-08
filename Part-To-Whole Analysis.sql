/* ---------------------------------------------------------
Part-To-Whole Analysis
Goal: Understand category contribution to total sales
--------------------------------------------------------- */

WITH category_sales AS (

SELECT 
    category,
    SUM(sales_amount) AS total_sales
FROM dbo.[gold.fact_sales] f
LEFT JOIN dbo.[gold.dim_products] p
ON f.product_key = p.product_key
GROUP BY category
)

SELECT 
    category,
    total_sales,

    SUM(total_sales) OVER () AS overall_sales,

    CONCAT(
        ROUND(
            CAST(total_sales AS FLOAT) /
            SUM(total_sales) OVER () * 100, 2
        ), '%'
    ) AS percentage_total

FROM category_sales
ORDER BY total_sales DESC;