-- 02 · Baseline: freight cost as % of GMV + distribution per order
.headers on
.mode column

WITH order_costs AS (
  SELECT oi.order_id,
         SUM(oi.price)         AS gmv,
         SUM(oi.freight_value) AS freight,
         COUNT(*)              AS n_items
  FROM olist_order_items oi
  JOIN olist_orders o ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY oi.order_id
)
SELECT COUNT(*)                                    AS delivered_orders,
       ROUND(SUM(gmv), 0)                          AS total_gmv,
       ROUND(SUM(freight), 0)                      AS total_freight,
       ROUND(100.0 * SUM(freight) / SUM(gmv), 2)   AS freight_pct_of_gmv,
       ROUND(AVG(freight), 2)                      AS avg_freight_per_order,
       ROUND(AVG(freight / NULLIF(gmv, 0)) * 100, 2) AS avg_freight_ratio_pct
FROM order_costs;

-- Distribution: freight ratio by decile (who pays the most relative to basket?)
WITH order_costs AS (
  SELECT oi.order_id, SUM(oi.price) AS gmv, SUM(oi.freight_value) AS freight
  FROM olist_order_items oi
  JOIN olist_orders o ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY oi.order_id
),
ranked AS (
  SELECT *, NTILE(10) OVER (ORDER BY freight / NULLIF(gmv, 0)) AS decile
  FROM order_costs WHERE gmv > 0
)
SELECT decile,
       COUNT(*)                                   AS orders,
       ROUND(AVG(100.0 * freight / gmv), 1)       AS avg_freight_pct,
       ROUND(AVG(gmv), 1)                         AS avg_basket
FROM ranked GROUP BY decile ORDER BY decile;
