-- 05 · Speed vs cost: are slow deliveries also expensive deliveries?
.headers on
.mode column

WITH delivered AS (
  SELECT o.order_id,
         JULIANDAY(o.order_delivered_customer_date) - JULIANDAY(o.order_purchase_timestamp) AS delivery_days,
         SUM(oi.freight_value) AS freight
  FROM olist_orders o
  JOIN olist_order_items oi ON oi.order_id = o.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
  GROUP BY o.order_id
  HAVING delivery_days BETWEEN 0 AND 60
),
quartiled AS (
  SELECT *, NTILE(4) OVER (ORDER BY delivery_days) AS speed_quartile
  FROM delivered
)
SELECT speed_quartile,
       COUNT(*)                       AS orders,
       ROUND(AVG(delivery_days), 1)   AS avg_days,
       ROUND(AVG(freight), 2)         AS avg_freight
FROM quartiled
GROUP BY speed_quartile ORDER BY speed_quartile;
-- Expected insight: the slowest quartile often ALSO carries the highest freight
-- (long lanes are slow AND expensive) -> speed and cost are not a trade-off on
-- these lanes; regionalization improves both. This mirrors Amazon's
-- regionalization logic in EU LTP transformation programs.
