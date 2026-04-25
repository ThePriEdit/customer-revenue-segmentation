-- ============================================================
-- 04_monthly_trends.sql
-- Customer Revenue & Segmentation Analysis
-- Purpose: Time-series analysis — monthly, quarterly, yearly
--          revenue trends and year-over-year comparisons
-- ============================================================


-- ------------------------------------------------------------
-- 1. MONTHLY REVENUE TREND
-- ------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM transaction_date)          AS year,
    EXTRACT(MONTH FROM transaction_date)         AS month,
    TO_CHAR(transaction_date, 'Mon YYYY')        AS month_label,
    COUNT(transaction_id)                        AS transactions,
    COUNT(DISTINCT customer_id)                  AS active_customers,
    ROUND(SUM(net_revenue)::NUMERIC, 0)          AS monthly_revenue,
    ROUND(AVG(net_revenue)::NUMERIC, 2)          AS avg_order_value
FROM transactions
GROUP BY 1, 2, 3
ORDER BY 1, 2;


-- ------------------------------------------------------------
-- 2. QUARTERLY REVENUE SUMMARY
-- ------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM transaction_date)                     AS year,
    'Q' || EXTRACT(QUARTER FROM transaction_date)           AS quarter,
    COUNT(transaction_id)                                   AS transactions,
    COUNT(DISTINCT customer_id)                             AS active_customers,
    ROUND(SUM(net_revenue)::NUMERIC, 0)                     AS quarterly_revenue
FROM transactions
GROUP BY 1, 2
ORDER BY 1, 2;


-- ------------------------------------------------------------
-- 3. YEAR-OVER-YEAR REVENUE COMPARISON (MONTHLY)
-- ------------------------------------------------------------
WITH monthly AS (
    SELECT
        EXTRACT(YEAR FROM transaction_date)  AS year,
        EXTRACT(MONTH FROM transaction_date) AS month,
        ROUND(SUM(net_revenue)::NUMERIC, 0)  AS monthly_revenue
    FROM transactions
    GROUP BY 1, 2
)
SELECT
    a.month,
    a.monthly_revenue                                   AS revenue_2023,
    b.monthly_revenue                                   AS revenue_2024,
    ROUND((b.monthly_revenue - a.monthly_revenue)
          ::NUMERIC, 0)                                 AS revenue_change,
    ROUND((b.monthly_revenue - a.monthly_revenue)
          * 100.0 / NULLIF(a.monthly_revenue, 0)
          , 1)                                          AS yoy_growth_pct
FROM monthly a
JOIN monthly b
  ON a.month = b.month
 AND a.year  = 2023
 AND b.year  = 2024
ORDER BY a.month;


-- ------------------------------------------------------------
-- 4. RUNNING CUMULATIVE REVENUE BY MONTH (2024)
-- ------------------------------------------------------------
WITH monthly AS (
    SELECT
        EXTRACT(MONTH FROM transaction_date)             AS month,
        TO_CHAR(transaction_date, 'Mon')                 AS month_name,
        ROUND(SUM(net_revenue)::NUMERIC, 0)              AS monthly_revenue
    FROM transactions
    WHERE EXTRACT(YEAR FROM transaction_date) = 2024
    GROUP BY 1, 2
)
SELECT
    month,
    month_name,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY month
                                ROWS BETWEEN UNBOUNDED PRECEDING
                                AND CURRENT ROW)         AS cumulative_revenue
FROM monthly
ORDER BY month;


-- ------------------------------------------------------------
-- 5. REVENUE BY QUARTER AND SEGMENT (TREND BY SEGMENT)
-- ------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM transaction_date)                  AS year,
    'Q' || EXTRACT(QUARTER FROM transaction_date)        AS quarter,
    segment,
    ROUND(SUM(net_revenue)::NUMERIC, 0)                  AS revenue
FROM transactions
GROUP BY 1, 2, 3
ORDER BY 1, 2, revenue DESC;


-- ------------------------------------------------------------
-- 6. NEW VS REPEAT CUSTOMER REVENUE TREND BY MONTH
-- ------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM transaction_date)          AS year,
    EXTRACT(MONTH FROM transaction_date)         AS month,
    is_repeat_customer,
    COUNT(transaction_id)                        AS transactions,
    ROUND(SUM(net_revenue)::NUMERIC, 0)          AS revenue
FROM transactions
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3;


-- ------------------------------------------------------------
-- 7. AVERAGE ORDER VALUE TREND BY MONTH
-- ------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM transaction_date)          AS year,
    EXTRACT(MONTH FROM transaction_date)         AS month,
    ROUND(AVG(net_revenue)::NUMERIC, 2)          AS avg_order_value,
    ROUND(AVG(discount_pct)::NUMERIC, 3)         AS avg_discount_rate
FROM transactions
GROUP BY 1, 2
ORDER BY 1, 2;
