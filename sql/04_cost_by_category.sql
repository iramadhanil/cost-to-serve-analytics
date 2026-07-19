-- 04 · Category economics: freight per kg and freight-to-price ratio
.headers on
.mode column

WITH item_costs AS (
  SELECT COALESCE(t.product_category_name_english, p.product_category_name) AS category,
         oi.freight_value, oi.price,
         p.product_weight_g / 1000.0 AS weight_kg
  FROM olist_order_items oi
  JOIN olist_orders o   ON o.order_id = oi.order_id AND o.order_status = 'delivered'
  JOIN olist_products p ON p.product_id = oi.product_id
  LEFT JOIN product_category_name_translation t
         ON t.product_category_name = p.product_category_name
  WHERE p.product_weight_g > 0 AND oi.price > 0
),
cat_agg AS (
  SELECT category,
         COUNT(*)                                     AS items,
         ROUND(AVG(freight_value), 2)                 AS avg_freight,
         ROUND(AVG(freight_value / weight_kg), 2)     AS freight_per_kg,
         ROUND(100.0 * AVG(freight_value / price), 1) AS freight_pct_of_price
  FROM item_costs GROUP BY category HAVING COUNT(*) >= 200
),
tiered AS (
  SELECT *, NTILE(10) OVER (ORDER BY freight_pct_of_price DESC) AS worst_decile
  FROM cat_agg
)
SELECT category, items, avg_freight, freight_per_kg, freight_pct_of_price
FROM tiered WHERE worst_decile = 1
ORDER BY freight_pct_of_price DESC;
