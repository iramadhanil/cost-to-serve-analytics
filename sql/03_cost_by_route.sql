-- 03 · Which shipping lanes (seller state -> customer state) drive freight cost?
.headers on
.mode column

WITH lane_costs AS (
  SELECT s.seller_state || ' -> ' || c.customer_state AS lane,
         (s.seller_state = c.customer_state)          AS intrastate,
         oi.freight_value, oi.price
  FROM olist_order_items oi
  JOIN olist_orders o    ON o.order_id = oi.order_id AND o.order_status = 'delivered'
  JOIN olist_customers c ON c.customer_id = o.customer_id
  JOIN olist_sellers s   ON s.seller_id = oi.seller_id
),
lane_agg AS (
  SELECT lane, intrastate,
         COUNT(*)                    AS shipments,
         ROUND(AVG(freight_value),2) AS avg_freight,
         ROUND(SUM(freight_value),0) AS total_freight,
         RANK() OVER (ORDER BY SUM(freight_value) DESC) AS cost_rank
  FROM lane_costs GROUP BY lane, intrastate
)
SELECT * FROM lane_agg WHERE cost_rank <= 15 ORDER BY cost_rank;

-- Interstate premium: how much more does crossing state lines cost?
WITH lane_costs AS (
  SELECT (s.seller_state = c.customer_state) AS intrastate, oi.freight_value
  FROM olist_order_items oi
  JOIN olist_orders o    ON o.order_id = oi.order_id AND o.order_status = 'delivered'
  JOIN olist_customers c ON c.customer_id = o.customer_id
  JOIN olist_sellers s   ON s.seller_id = oi.seller_id
)
SELECT CASE intrastate WHEN 1 THEN 'intrastate' ELSE 'interstate' END AS flow,
       COUNT(*) AS shipments,
       ROUND(AVG(freight_value), 2) AS avg_freight,
       ROUND(100.0 * SUM(freight_value) / (SELECT SUM(freight_value) FROM lane_costs), 1) AS pct_of_total_freight
FROM lane_costs GROUP BY intrastate;
