-- ============================================================
-- 01_data_exploration.sql
-- Customer Revenue & Segmentation Analysis
-- Purpose: Initial data overview, row counts, data quality checks
-- ============================================================


-- ------------------------------------------------------------
-- 1. TOTAL ROW COUNT & DATE RANGE
-- ------------------------------------------------------------
SELECT
    COUNT(*)                            AS total_transactions,
    COUNT(DISTINCT customer_id)         AS unique_customers,
    MIN(transaction_date)               AS earliest_date,
    MAX(transaction_date)               AS latest_date,
    ROUND(SUM(net_revenue)::NUMERIC, 0) AS total_net_revenue
FROM transactions;


-- ------------------------------------------------------------
-- 2. COLUMN-LEVEL NULL CHECK
-- ------------------------------------------------------------
SELECT
    COUNT(*) - COUNT(transaction_id)      AS null_transaction_id,
    COUNT(*) - COUNT(customer_id)         AS null_customer_id,
    COUNT(*) - COUNT(segment)             AS null_segment,
    COUNT(*) - COUNT(region)              AS null_region,
    COUNT(*) - COUNT(product)             AS null_product,
    COUNT(*) - COUNT(transaction_date)    AS null_date,
    COUNT(*) - COUNT(revenue)             AS null_revenue,
    COUNT(*) - COUNT(net_revenue)         AS null_net_revenue
FROM transactions;


-- ------------------------------------------------------------
-- 3. DUPLICATE TRANSACTION CHECK
-- ------------------------------------------------------------
SELECT
    transaction_id,
    COUNT(*) AS occurrences
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;


-- ------------------------------------------------------------
-- 4. REVENUE DISTRIBUTION SUMMARY
-- ------------------------------------------------------------
SELECT
    ROUND(MIN(net_revenue)::NUMERIC, 2)                 AS min_revenue,
    ROUND(MAX(net_revenue)::NUMERIC, 2)                 AS max_revenue,
    ROUND(AVG(net_revenue)::NUMERIC, 2)                 AS avg_revenue,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP
          (ORDER BY net_revenue)::NUMERIC, 2)           AS median_revenue,
    ROUND(STDDEV(net_revenue)::NUMERIC, 2)              AS stddev_revenue
FROM transactions;


-- ------------------------------------------------------------
-- 5. DISTINCT VALUES PER CATEGORICAL COLUMN
-- ------------------------------------------------------------
SELECT 'segment'  AS column_name, COUNT(DISTINCT segment)  AS distinct_values FROM transactions
UNION ALL
SELECT 'region',                   COUNT(DISTINCT region)                       FROM transactions
UNION ALL
SELECT 'industry',                 COUNT(DISTINCT industry)                     FROM transactions
UNION ALL
SELECT 'channel',                  COUNT(DISTINCT channel)                      FROM transactions
UNION ALL
SELECT 'product',                  COUNT(DISTINCT product)                      FROM transactions;


-- ------------------------------------------------------------
-- 6. TRANSACTION VOLUME BY YEAR
-- ------------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM transaction_date) AS year,
    COUNT(*)                            AS transactions,
    COUNT(DISTINCT customer_id)         AS unique_customers,
    ROUND(SUM(net_revenue)::NUMERIC, 0) AS net_revenue
FROM transactions
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------------------------
-- 7. DISCOUNT RANGE OVERVIEW
-- ------------------------------------------------------------
SELECT
    ROUND(MIN(discount_pct)::NUMERIC, 2) AS min_discount,
    ROUND(MAX(discount_pct)::NUMERIC, 2) AS max_discount,
    ROUND(AVG(discount_pct)::NUMERIC, 3) AS avg_discount
FROM transactions;


-- ------------------------------------------------------------
-- 8. SAMPLE RECORDS
-- ------------------------------------------------------------
SELECT *
FROM transactions
ORDER BY transaction_date DESC
LIMIT 10;
