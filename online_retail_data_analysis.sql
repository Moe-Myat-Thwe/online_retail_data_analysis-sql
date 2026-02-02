-- Online Retail Data Analysis using SQL

-- ===================================================================================================================================================================
-- 1. Sales Performance Analysis
-- ===================================================================================================================================================================

-- Total revenue
SELECT ROUND(SUM(quantity * unit_price), 2) AS total_revenue
FROM online_retail_cleaned
WHERE quantity > 0 AND unit_price > 0;

-- Revenue by month
SELECT 
    DATE_FORMAT(STR_TO_DATE(invoice_date, '%d-%m-%Y'), '%Y-%m') AS month, 
    -- Assumed invoice_date format = %d-%m-%Y
    
	ROUND(SUM(quantity * unit_price), 2) AS revenue
FROM online_retail_cleaned
WHERE quantity > 0 AND unit_price > 0
GROUP BY month
ORDER BY revenue DESC;
-- Insight: Revenue peaks in May–June.

-- Revenue by country
SELECT country, ROUND(SUM(quantity * unit_price), 2) AS revenue
FROM online_retail_cleaned
WHERE quantity > 0 AND unit_price > 0
GROUP BY country
ORDER BY revenue DESC;
-- Insight: UK dominates the revenue, possibily the UK has the highest demand.

-- ===================================================================================================================================================================
-- 2. Best-selling Products
-- ===================================================================================================================================================================

-- Top 10 best seller items
SELECT description,
       SUM(quantity) AS total_quantity
FROM online_retail_cleaned
GROUP BY description
ORDER BY total_quantity DESC
LIMIT 10;
-- Insight: Top seller items are mostly Home Décor and Ornaments; Kitchen and Baking Supplies; Storage and Bags; Party and Gift Accessories.
 
-- Most profitable products
SELECT description,
       ROUND(SUM(quantity * unit_price), 2) AS revenue,
       ROUND(100 * SUM(quantity * unit_price) / SUM(SUM(quantity * unit_price)) OVER (), 2) AS revenue_share_pct
FROM online_retail_cleaned
GROUP BY description
ORDER BY revenue DESC
LIMIT 10;

-- Product Profitability Matrix
SELECT 
    description,
    SUM(quantity) AS total_qty,
    ROUND(SUM(quantity * unit_price), 2) AS revenue,
    COUNT(DISTINCT invoice_num) AS num_transactions,
    COUNT(DISTINCT customer_id) AS num_customers
FROM online_retail_cleaned
GROUP BY description
ORDER BY revenue DESC;

-- ===================================================================================================================================================================
-- 3. Customer Behavior Analysis
-- ===================================================================================================================================================================

-- Top customers (by revenue)
SELECT customer_id,
       ROUND(SUM(quantity * unit_price), 2) AS revenue
FROM online_retail_cleaned
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 10;

-- Customer purchase frequency
SELECT customer_id,
       COUNT(DISTINCT invoice_num) AS num_orders
FROM online_retail_cleaned
GROUP BY customer_id
ORDER BY num_orders DESC;

-- RFM Customer Segmentation
-- Step 1: Recency, Frequency, Monetary
WITH customer_rfm AS (
    SELECT
        customer_id,
        DATEDIFF(
            (SELECT MAX(STR_TO_DATE(invoice_date, '%d-%m-%Y') ) FROM online_retail_cleaned),
            MAX(STR_TO_DATE(invoice_date, '%d-%m-%Y'))
        ) AS recency,
        COUNT(DISTINCT invoice_num) AS frequency,
        ROUND(SUM(quantity * unit_price) ,2) AS monetary
    FROM online_retail_cleaned
    GROUP BY customer_id
)
SELECT * FROM customer_rfm;

-- Step 2: Add RFM Scores (1–5)
-- Higher RFM score = better customer

WITH rfm AS (
    SELECT
        customer_id,
        NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
    FROM (
        SELECT
            customer_id,
            DATEDIFF(
            (SELECT MAX(STR_TO_DATE(invoice_date, '%d-%m-%Y') ) FROM online_retail_cleaned),
            MAX(STR_TO_DATE(invoice_date, '%d-%m-%Y'))
        ) AS recency,
            COUNT(DISTINCT invoice_num) AS frequency,
            ROUND(SUM(quantity * unit_price) ,2) AS monetary
        FROM online_retail_cleaned
        GROUP BY customer_id
    ) t
)
SELECT *, (r_score + f_score + m_score) AS rfm_score
FROM rfm
ORDER BY rfm_score DESC;

-- Customer Cohort Analysis (Retention)
-- cohort_month = when the customer first appeared
WITH cohort AS (
    SELECT 
        c.customer_id,
        DATE_FORMAT(STR_TO_DATE(c.invoice_date, '%d-%m-%Y'), '%Y-%m') AS purchase_month,
        fp.cohort_month
    FROM online_retail_cleaned c

    JOIN (
        SELECT customer_id, DATE_FORMAT(MIN(STR_TO_DATE(invoice_date, '%d-%m-%Y')), '%Y-%m') AS cohort_month 
        FROM online_retail_cleaned
        GROUP BY customer_id
    ) fp ON c.customer_id = fp.customer_id
)
SELECT cohort_month,
       purchase_month,
       COUNT(DISTINCT customer_id) AS customers
FROM cohort
GROUP BY cohort_month, purchase_month
ORDER BY cohort_month, purchase_month;

/*Cohort analysis groups customers by their first purchase month to analyze retention behavior over time. 
This approach helps identify churn patterns, compare customer quality across acquisition periods,
 and evaluate long-term customer engagement beyond aggregate metrics.*/


-- ===================================================================================================================================================================
-- 4. Basket Analysis (Market Basket Analysis)
-- ===================================================================================================================================================================

-- Average basket size
SELECT ROUND(AVG(item_count)) AS basket_size, ROUND(AVG(total_value), 2) as average_value
FROM (
    SELECT invoice_num, COUNT(*) AS item_count, SUM(quantity * unit_price) as total_value
    FROM online_retail_cleaned
    GROUP BY invoice_num
) t;

-- ===================================================================================================================================================================
-- 5. Time Series Patterns
-- ===================================================================================================================================================================

-- Daily sales trend
SELECT invoice_date,
      ROUND(SUM(quantity * unit_price)) AS daily_sales
FROM online_retail_cleaned
GROUP BY invoice_date
ORDER BY invoice_date;

-- Day-of-Week Revenue Pattern (Seasonality)
SELECT 
    DAYNAME(STR_TO_DATE(invoice_date, '%d-%m-%Y')) AS weekday,
    ROUND(SUM(quantity * unit_price) ) AS revenue
FROM online_retail_cleaned
GROUP BY weekday
ORDER BY revenue DESC;
-- Insight: Tuesday and Thursday have the highest revenue.


-- =========================================================================================================================================================================
-- 6. Summary View for Dashboards
-- =========================================================================================================================================================================

CREATE OR REPLACE VIEW onlineretail_summary AS
WITH cohort AS (
    SELECT 
        customer_id,
        DATE_FORMAT(
            MIN(STR_TO_DATE(invoice_date, '%d-%m-%Y')), '%Y-%m'
        ) AS cohort_month
    FROM online_retail_cleaned
    GROUP BY customer_id
),
basket AS (
    SELECT 
        invoice_num,
        COUNT(*) AS basket_size
    FROM online_retail_cleaned
    GROUP BY invoice_num
)
SELECT
    c.invoice_num,
    c.stock_code,
    c.`description`,
    c.quantity,
    c.unit_price,
    ROUND(c.quantity * c.unit_price, 2) AS revenue,

    c.customer_id,
    c.country,

    STR_TO_DATE(c.invoice_date, '%d-%m-%Y') AS invoice_date,
    DATE_FORMAT(STR_TO_DATE(c.invoice_date, '%d-%m-%Y'), '%Y-%m') AS invoice_month,
    DAYNAME(STR_TO_DATE(c.invoice_date, '%d-%m-%Y')) AS weekday,

    h.cohort_month,
    b.basket_size

FROM online_retail_cleaned c
LEFT JOIN cohort h ON c.customer_id = h.customer_id
LEFT JOIN basket b ON c.invoice_num = b.invoice_num;

   
-- select * from onlineretail_summary;


