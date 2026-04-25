-- ============================================================
-- 02_pareto_analysis.sql
-- Customer Revenue & Segmentation Analysis
-- Purpose: Identify top 20% customers driving ~80% of revenue
--          (Pareto / 80-20 Rule Analysis)
-- ============================================================


-- ------------------------------------------------------------
-- 1. CUSTOMER-LEVEL REVENUE AGGREGATION
-- ------------------------------------------------------------
WITH customer_revenue AS (
    SELECT
        customer_id,
        segment,
        region,
        SUM(net_revenue)              AS total_revenue,
        COUNT(transaction_id)         AS total_transactions,
        ROUND(AVG(net_revenue)::NUMERIC, 2) AS avg_transaction_value,
        MIN(transaction_date)         AS first_purchase,
        MAX(transaction_date)         AS last_purchase
    FROM transactions
    GROUP BY customer_id, segment, region
),

-- ------------------------------------------------------------
-- 2. RANK CUSTOMERS BY REVENUE (HIGHEST FIRST)
-- ------------------------------------------------------------
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC)          AS revenue_rank,
        NTILE(5)      OVER (ORDER BY total_revenue DESC)          AS revenue_quintile,
        SUM(total_revenue) OVER ()                                AS grand_total,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC
                                 ROWS BETWEEN UNBOUNDED PRECEDING
                                 AND CURRENT ROW)                 AS cumulative_revenue
    FROM customer_revenue
)

-- ------------------------------------------------------------
-- 3. PARETO TABLE WITH CUMULATIVE %
-- ------------------------------------------------------------
SELECT
    customer_id,
    segment,
    region,
    ROUND(total_revenue::NUMERIC, 0)                              AS total_revenue,
    total_transactions,
    avg_transaction_value,
    revenue_rank,
    CASE
        WHEN revenue_quintile = 1 THEN 'Top 20%'
        ELSE 'Bottom 80%'
    END                                                           AS customer_tier,
    ROUND((total_revenue / grand_total * 100)::NUMERIC, 2)        AS revenue_share_pct,
    ROUND((cumulative_revenue / grand_total * 100)::NUMERIC, 2)   AS cumulative_revenue_pct
FROM ranked
ORDER BY revenue_rank;


-- ============================================================
-- 4. PARETO SUMMARY — WHAT % OF REVENUE COMES FROM TOP 20%?
-- ============================================================
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(net_revenue) AS total_revenue
    FROM transactions
    GROUP BY customer_id
),
ranked AS (
    SELECT
        customer_id,
        total_revenue,
        NTILE(5) OVER (ORDER BY total_revenue DESC) AS revenue_quintile
    FROM customer_revenue
)
SELECT
    CASE WHEN revenue_quintile = 1 THEN 'Top 20%' ELSE 'Bottom 80%' END AS customer_tier,
    COUNT(*)                                                               AS customer_count,
    ROUND(SUM(total_revenue)::NUMERIC, 0)                                  AS total_revenue,
    ROUND(SUM(total_revenue) * 100.0
          / SUM(SUM(total_revenue)) OVER ()
          , 1)                                                             AS revenue_share_pct
FROM ranked
GROUP BY 1
ORDER BY total_revenue DESC;


-- ============================================================
-- 5. TOP 20 INDIVIDUAL CUSTOMERS (FOR RETENTION TARGETING)
-- ============================================================
SELECT
    customer_id,
    segment,
    region,
    ROUND(SUM(net_revenue)::NUMERIC, 0)   AS total_revenue,
    COUNT(transaction_id)                  AS transactions,
    ROUND(AVG(net_revenue)::NUMERIC, 2)   AS avg_order_value,
    MAX(transaction_date)                  AS last_purchase_date
FROM transactions
GROUP BY customer_id, segment, region
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================
-- 6. DECILE ANALYSIS — REVENUE CONTRIBUTION BY EACH 10%
-- ============================================================
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(net_revenue) AS total_revenue
    FROM transactions
    GROUP BY customer_id
),
deciled AS (
    SELECT
        customer_id,
        total_revenue,
        NTILE(10) OVER (ORDER BY total_revenue DESC) AS decile
    FROM customer_revenue
)
SELECT
    decile,
    COUNT(*)                                                        AS customers,
    ROUND(SUM(total_revenue)::NUMERIC, 0)                           AS revenue,
    ROUND(SUM(total_revenue) * 100.0
          / SUM(SUM(total_revenue)) OVER ()
          , 1)                                                      AS revenue_pct
FROM deciled
GROUP BY decile
ORDER BY decile;
