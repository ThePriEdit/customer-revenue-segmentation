-- ============================================================
-- 03_segment_region_analysis.sql
-- Customer Revenue & Segmentation Analysis
-- Purpose: Revenue breakdown by segment, region, channel,
--          product, and industry
-- ============================================================


-- ------------------------------------------------------------
-- 1. REVENUE BY CUSTOMER SEGMENT
-- ------------------------------------------------------------
SELECT
    segment,
    COUNT(DISTINCT customer_id)             AS unique_customers,
    COUNT(transaction_id)                   AS total_transactions,
    ROUND(SUM(net_revenue)::NUMERIC, 0)     AS total_revenue,
    ROUND(AVG(net_revenue)::NUMERIC, 2)     AS avg_transaction_value,
    ROUND(SUM(net_revenue) * 100.0
          / SUM(SUM(net_revenue)) OVER ()
          , 1)                              AS revenue_share_pct
FROM transactions
GROUP BY segment
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 2. REVENUE BY REGION
-- ------------------------------------------------------------
SELECT
    region,
    COUNT(DISTINCT customer_id)             AS unique_customers,
    COUNT(transaction_id)                   AS total_transactions,
    ROUND(SUM(net_revenue)::NUMERIC, 0)     AS total_revenue,
    ROUND(AVG(net_revenue)::NUMERIC, 2)     AS avg_order_value,
    ROUND(SUM(net_revenue) * 100.0
          / SUM(SUM(net_revenue)) OVER ()
          , 1)                              AS revenue_share_pct
FROM transactions
GROUP BY region
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 3. REVENUE BY ACQUISITION CHANNEL
-- ------------------------------------------------------------
SELECT
    channel,
    COUNT(DISTINCT customer_id)             AS unique_customers,
    COUNT(transaction_id)                   AS transactions,
    ROUND(SUM(net_revenue)::NUMERIC, 0)     AS total_revenue,
    ROUND(AVG(net_revenue)::NUMERIC, 2)     AS avg_transaction_value,
    ROUND(SUM(net_revenue) * 100.0
          / SUM(SUM(net_revenue)) OVER ()
          , 1)                              AS revenue_share_pct
FROM transactions
GROUP BY channel
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 4. REVENUE BY PRODUCT
-- ------------------------------------------------------------
SELECT
    product,
    COUNT(transaction_id)                   AS transactions,
    ROUND(SUM(units_sold)::NUMERIC, 0)      AS total_units_sold,
    ROUND(SUM(net_revenue)::NUMERIC, 0)     AS total_revenue,
    ROUND(AVG(net_revenue)::NUMERIC, 2)     AS avg_revenue_per_txn,
    ROUND(SUM(net_revenue) * 100.0
          / SUM(SUM(net_revenue)) OVER ()
          , 1)                              AS revenue_share_pct
FROM transactions
GROUP BY product
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 5. REVENUE BY INDUSTRY
-- ------------------------------------------------------------
SELECT
    industry,
    COUNT(DISTINCT customer_id)             AS unique_customers,
    ROUND(SUM(net_revenue)::NUMERIC, 0)     AS total_revenue,
    ROUND(AVG(net_revenue)::NUMERIC, 2)     AS avg_order_value,
    ROUND(SUM(net_revenue) * 100.0
          / SUM(SUM(net_revenue)) OVER ()
          , 1)                              AS revenue_share_pct
FROM transactions
GROUP BY industry
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 6. SEGMENT × REGION CROSS-ANALYSIS (HEATMAP DATA)
-- ------------------------------------------------------------
SELECT
    segment,
    region,
    COUNT(DISTINCT customer_id)             AS customers,
    ROUND(SUM(net_revenue)::NUMERIC, 0)     AS total_revenue,
    ROUND(AVG(net_revenue)::NUMERIC, 2)     AS avg_order_value
FROM transactions
GROUP BY segment, region
ORDER BY segment, total_revenue DESC;


-- ------------------------------------------------------------
-- 7. SEGMENT × CHANNEL CROSS-ANALYSIS
-- ------------------------------------------------------------
SELECT
    segment,
    channel,
    COUNT(DISTINCT customer_id)             AS customers,
    ROUND(SUM(net_revenue)::NUMERIC, 0)     AS total_revenue
FROM transactions
GROUP BY segment, channel
ORDER BY segment, total_revenue DESC;


-- ------------------------------------------------------------
-- 8. PRODUCT PERFORMANCE BY SEGMENT
-- ------------------------------------------------------------
SELECT
    segment,
    product,
    ROUND(SUM(net_revenue)::NUMERIC, 0)     AS total_revenue,
    COUNT(transaction_id)                   AS transactions
FROM transactions
GROUP BY segment, product
ORDER BY segment, total_revenue DESC;
