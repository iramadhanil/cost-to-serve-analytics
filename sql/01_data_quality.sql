-- 01 · Data quality: can we trust the numbers?
.headers on
.mode column

-- Row counts per core table
SELECT 'orders' AS tbl, COUNT(*) AS rows FROM olist_orders
UNION ALL SELECT 'order_items', COUNT(*) FROM olist_order_items
UNION ALL SELECT 'products',   COUNT(*) FROM olist_products
UNION ALL SELECT 'customers',  COUNT(*) FROM olist_customers
UNION ALL SELECT 'sellers',    COUNT(*) FROM olist_sellers;

-- Null / zero freight check
SELECT COUNT(*)                                   AS items_total,
       SUM(freight_value IS NULL)                 AS freight_null,
       SUM(freight_value = 0)                     AS freight_zero,
       ROUND(100.0 * SUM(freight_value = 0) / COUNT(*), 2) AS pct_zero
FROM olist_order_items;

-- Duplicate order ids (should be 0)
SELECT COUNT(*) AS dup_orders FROM (
  SELECT order_id FROM olist_orders GROUP BY order_id HAVING COUNT(*) > 1
);

-- Orders missing delivery timestamps (excluded from speed analysis)
SELECT order_status, COUNT(*) AS n,
       SUM(order_delivered_customer_date IS NULL) AS missing_delivery_ts
FROM olist_orders GROUP BY order_status ORDER BY n DESC;
