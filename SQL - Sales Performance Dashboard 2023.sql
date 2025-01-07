/* Sales Performance Dashboard */

--Query 1: Rolling 3-Month Sales Performance by Region
WITH sales_summary AS (
    SELECT 
        r.region_name,
        DATE_TRUNC('month', s.date) AS sales_month,
        SUM(s.sales_amount) AS total_sales
    FROM 
        sales s
    JOIN 
        regions r ON s.region_id = r.region_id
    GROUP BY 
        r.region_name, DATE_TRUNC('month', s.date)
)
SELECT 
    region_name,
    sales_month,
    total_sales,
    AVG(total_sales) OVER (PARTITION BY region_name ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3_month_sales
FROM 
    sales_summary
ORDER BY 
    region_name, sales_month;

--Query 2: Contribution Margin by Product
SELECT 
    p.product_name,
    p.category,
    SUM(s.sales_amount) - SUM(p.price * s.quantity) AS contribution_margin,
    SUM(s.sales_amount) AS total_sales
FROM 
    sales s
JOIN 
    products p ON s.product_id = p.product_id
GROUP BY 
    p.product_name, p.category
ORDER BY 
    contribution_margin DESC;

--Query 3: Regional Sales Target Achievement with Percentile Ranking
WITH region_performance AS (
    SELECT 
        r.region_name,
        SUM(s.sales_amount) AS total_sales,
        r.sales_target,
        SUM(s.sales_amount) * 100.0 / r.sales_target AS target_achievement
    FROM 
        sales s
    JOIN 
        regions r ON s.region_id = r.region_id
    GROUP BY 
        r.region_name, r.sales_target
)
SELECT 
    region_name,
    total_sales,
    sales_target,
    target_achievement,
    NTILE(4) OVER (ORDER BY target_achievement DESC) AS performance_quartile
FROM 
    region_performance;

