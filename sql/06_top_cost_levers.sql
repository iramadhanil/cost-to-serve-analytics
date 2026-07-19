-- 06 · Synthesis: quantify the top-3 cost levers
.headers on
.mode column

-- Lever 1: interstate long-haul concentration
WITH lane AS (
  SELECT (s.seller_state = c.customer_state) AS intra, oi.freight_value
  FROM olist_order_items oi
  JOIN olist_orders o    ON o.order_id = oi.order_id AND o.order_status='delivered'
  JOIN olist_customers c ON c.customer_id = o.customer_id
  JOIN olist_sellers s   ON s.seller_id = oi.seller_id
)
SELECT 'L1: interstate share of freight spend' AS lever,
       ROUND(100.0 * SUM(CASE WHEN intra=0 THEN freight_value END) / SUM(freight_value), 1) AS value_pct
FROM lane;

-- Lever 2: worst-decile categories' share of freight
WITH item_costs AS (
  SELECT p.product_category_name AS category, oi.freight_value, oi.price
  FROM olist_order_items oi
  JOIN olist_orders o   ON o.order_id = oi.order_id AND o.order_status='delivered'
  JOIN olist_products p ON p.product_id = oi.product_id
  WHERE oi.price > 0
),
cat AS (
  SELECT category, SUM(freight_value) AS freight,
         AVG(freight_value/price) AS ratio,
         NTILE(10) OVER (ORDER BY AVG(freight_value/price) DESC) AS d
  FROM item_costs GROUP BY category
)
SELECT 'L2: worst-decile categories share of freight' AS lever,
       ROUND(100.0 * SUM(CASE WHEN d=1 THEN freight END) / SUM(freight), 1) AS value_pct
FROM cat;

-- Lever 3: multi-seller split-shipment share (consolidation opportunity)
WITH per_order AS (
  SELECT oi.order_id, COUNT(DISTINCT oi.seller_id) AS sellers, SUM(oi.freight_value) AS freight
  FROM olist_order_items oi
  JOIN olist_orders o ON o.order_id = oi.order_id AND o.order_status='delivered'
  GROUP BY oi.order_id
)
SELECT 'L3: split-shipment (multi-seller) orders' AS lever,
       ROUND(100.0 * SUM(CASE WHEN sellers > 1 THEN 1 END) / COUNT(*), 1) AS pct_of_orders,
       ROUND(AVG(CASE WHEN sellers > 1 THEN freight END), 2)              AS avg_freight_split,
       ROUND(AVG(CASE WHEN sellers = 1 THEN freight END), 2)              AS avg_freight_single
FROM per_order;
