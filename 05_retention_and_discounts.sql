-- ============================================================
-- 05_retention_and_discounts.sql
-- Customer Revenue & Segmentation Analysis
-- Purpose: Repeat customer behaviour, retention indicators,
--          discount usage, and margin leakage analysis
-- ============================================================


-- ------------------------------------------------------------
-- 1. REPEAT VS NEW CUSTOMER SPLIT
-- ------------------------------------------------------------
SELECT
    CASE WHEN is_repeat_customer = 1 THEN 'Repeat Customer'
         ELSE 'New Customer'
    END                                                     AS customer_type,
    COUNT(transaction_id)                                   AS transactions,
    COUNT(DISTINCT customer_id)                             AS unique_customers,
    ROUND(SUM(net_revenue)::NUMERIC, 0)                     AS total_revenue,
    ROUND(AVG(net_revenue)::NUMERIC, 2)                     AS avg_order_value,
    ROUND(SUM(net_revenue) * 100.0
          / SUM(SUM(net_revenue)) OVER ()
          , 1)                                              AS revenue_share_pct
FROM transactions
GROUP BY 1
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 2. REPEAT CUSTOMER RATE BY SEGMENT
-- ------------------------------------------------------------
SELECT
    segment,
    COUNT(DISTINCT customer_id)                             AS total_customers,
    SUM(is_repeat_customer)                                 AS repeat_transactions,
    COUNT(transaction_id)                                   AS total_transactions,
    ROUND(SUM(is_repeat_customer) * 100.0
          / COUNT(transaction_id)
          , 1)                                              AS repeat_rate_pct
FROM transactions
GROUP BY segment
ORDER BY repeat_rate_pct DESC;


-- ------------------------------------------------------------
-- 3. CUSTOMER TENURE ANALYSIS
--    (How long customers have been with the company)
-- ------------------------------------------------------------
SELECT
    customer_since_year,
    COUNT(DISTINCT customer_id)                             AS customers,
    ROUND(SUM(net_revenue)::NUMERIC, 0)                     AS total_revenue,
    ROUND(AVG(net_revenue)::NUMERIC, 2)                     AS avg_order_value,
    ROUND(AVG(support_tickets)::NUMERIC, 1)                 AS avg_support_tickets
FROM transactions
GROUP BY customer_since_year
ORDER BY customer_since_year;


-- ------------------------------------------------------------
-- 4. DISCOUNT ANALYSIS BY SEGMENT
--    Identifies where discounts may be eroding margin
-- ------------------------------------------------------------
SELECT
    segment,
    COUNT(transaction_id)                                   AS transactions,
    ROUND(SUM(revenue)::NUMERIC, 0)                         AS gross_revenue,
    ROUND(SUM(net_revenue)::NUMERIC, 0)                     AS net_revenue,
    ROUND((SUM(revenue) - SUM(net_revenue))::NUMERIC, 0)    AS total_discount_given,
    ROUND(AVG(discount_pct) * 100
          , 1)                                              AS avg_discount_pct,
    ROUND((SUM(revenue) - SUM(net_revenue))
          * 100.0 / NULLIF(SUM(revenue), 0)
          , 1)                                              AS effective_discount_pct
FROM transactions
GROUP BY segment
ORDER BY effective_discount_pct DESC;


-- ------------------------------------------------------------
-- 5. MARGIN LEAKAGE — ARE TOP CUSTOMERS GETTING SAME DISCOUNTS?
--    Compare discount rates between top 20% and bottom 80%
-- ------------------------------------------------------------
WITH customer_totals AS (
    SELECT
        customer_id,
        SUM(net_revenue)    AS total_revenue,
        NTILE(5) OVER (ORDER BY SUM(net_revenue) DESC) AS quintile
    FROM transactions
    GROUP BY customer_id
)
SELECT
    CASE WHEN c.quintile = 1 THEN 'Top 20% Customers'
         ELSE 'Bottom 80% Customers'
    END                                                     AS customer_tier,
    COUNT(t.transaction_id)                                 AS transactions,
    ROUND(AVG(t.discount_pct) * 100, 1)                    AS avg_discount_pct,
    ROUND(SUM(t.revenue)::NUMERIC, 0)                       AS gross_revenue,
    ROUND(SUM(t.net_revenue)::NUMERIC, 0)                   AS net_revenue,
    ROUND((SUM(t.revenue) - SUM(t.net_revenue))::NUMERIC, 0) AS revenue_lost_to_discounts
FROM transactions t
JOIN customer_totals c USING (customer_id)
GROUP BY 1
ORDER BY net_revenue DESC;


-- ------------------------------------------------------------
-- 6. SUPPORT TICKET BURDEN BY SEGMENT
--    High tickets + low revenue = low-value high-cost customers
-- ------------------------------------------------------------
SELECT
    segment,
    COUNT(DISTINCT customer_id)                              AS customers,
    ROUND(SUM(net_revenue)::NUMERIC, 0)                      AS total_revenue,
    SUM(support_tickets)                                     AS total_tickets,
    ROUND(AVG(support_tickets)::NUMERIC, 2)                  AS avg_tickets_per_txn,
    ROUND(SUM(net_revenue) / NULLIF(SUM(support_tickets),0)
          ::NUMERIC, 0)                                      AS revenue_per_ticket
FROM transactions
GROUP BY segment
ORDER BY revenue_per_ticket DESC;


-- ------------------------------------------------------------
-- 7. CUSTOMERS AT CHURN RISK
--    (No transaction in the last 6 months of data window)
-- ------------------------------------------------------------
WITH last_purchase AS (
    SELECT
        customer_id,
        segment,
        region,
        MAX(transaction_date)                AS last_purchase_date,
        ROUND(SUM(net_revenue)::NUMERIC, 0)  AS lifetime_revenue
    FROM transactions
    GROUP BY customer_id, segment, region
),
data_window_end AS (
    SELECT MAX(transaction_date) AS max_date FROM transactions
)
SELECT
    lp.customer_id,
    lp.segment,
    lp.region,
    lp.last_purchase_date,
    lp.lifetime_revenue,
    (dw.max_date - lp.last_purchase_date)    AS days_since_last_purchase,
    CASE
        WHEN (dw.max_date - lp.last_purchase_date) > 180 THEN 'High Risk'
        WHEN (dw.max_date - lp.last_purchase_date) > 90  THEN 'Medium Risk'
        ELSE 'Active'
    END                                      AS churn_risk
FROM last_purchase lp
CROSS JOIN data_window_end dw
ORDER BY days_since_last_purchase DESC;


-- ------------------------------------------------------------
-- 8. HIGH-VALUE CUSTOMERS AT CHURN RISK (PRIORITY LIST)
--    Top 20% customers who haven't purchased in 90+ days
-- ------------------------------------------------------------
WITH customer_rev AS (
    SELECT
        customer_id,
        SUM(net_revenue)    AS total_revenue,
        MAX(transaction_date) AS last_purchase,
        NTILE(5) OVER (ORDER BY SUM(net_revenue) DESC) AS quintile
    FROM transactions
    GROUP BY customer_id
),
data_end AS (SELECT MAX(transaction_date) AS max_date FROM transactions)
SELECT
    cr.customer_id,
    ROUND(cr.total_revenue::NUMERIC, 0)     AS lifetime_revenue,
    cr.last_purchase,
    (de.max_date - cr.last_purchase)        AS days_inactive
FROM customer_rev cr
CROSS JOIN data_end de
WHERE cr.quintile = 1
  AND (de.max_date - cr.last_purchase) > 90
ORDER BY cr.total_revenue DESC;
