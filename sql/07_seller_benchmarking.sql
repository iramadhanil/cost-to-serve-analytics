-- 07 · Supplier (seller) freight benchmarking — the purchasing / target-costing view
-- Question: on the same shipping lane, which sellers ship at above-benchmark freight
-- cost, and what is the savings opportunity if each were brought to the lane median?
-- This is supplier should-cost benchmarking applied to e-commerce:
-- the lane median = "should-cost"; the gap vs median = the negotiation agenda.
.headers on
.mode column

-- Materialize once for speed (110k+ rows scanned twice otherwise)
DROP TABLE IF EXISTS lane_items;
CREATE TEMP TABLE lane_items AS
SELECT oi.seller_id,
       s.seller_state || ' -> ' || c.customer_state AS lane,
       oi.freight_value
FROM olist_order_items oi
JOIN olist_orders o    ON o.order_id = oi.order_id
JOIN olist_customers c ON c.customer_id = o.customer_id
JOIN olist_sellers s   ON s.seller_id = oi.seller_id
WHERE o.order_status = 'delivered' AND oi.freight_value > 0;
CREATE INDEX tmp_lane ON lane_items(lane);

DROP TABLE IF EXISTS lane_benchmark;
CREATE TEMP TABLE lane_benchmark AS      -- median freight per lane = should-cost
SELECT lane, freight_value AS lane_median
FROM (
    SELECT lane, freight_value,
           ROW_NUMBER() OVER (PARTITION BY lane ORDER BY freight_value) AS rn,
           COUNT(*)     OVER (PARTITION BY lane) AS n
    FROM lane_items
)
WHERE rn = (n + 1) / 2;

-- 7a · Top negotiation targets: high-volume sellers shipping above lane benchmark
SELECT li.seller_id,
       li.lane,
       COUNT(*)                                                  AS shipments,
       ROUND(AVG(li.freight_value), 2)                           AS seller_avg,
       lb.lane_median,
       ROUND(AVG(li.freight_value) - lb.lane_median, 2)          AS gap_vs_benchmark,
       ROUND((AVG(li.freight_value) - lb.lane_median) * COUNT(*), 0) AS savings_if_at_median
FROM lane_items li
JOIN lane_benchmark lb ON lb.lane = li.lane
GROUP BY li.seller_id, li.lane
HAVING COUNT(*) >= 50 AND AVG(li.freight_value) > lb.lane_median
ORDER BY savings_if_at_median DESC
LIMIT 15;

-- 7b · Size of the prize: total freight spend above lane benchmark
SELECT ROUND(SUM(li.freight_value), 0)                            AS total_freight,
       ROUND(SUM(MAX(li.freight_value - lb.lane_median, 0)), 0)   AS spend_above_benchmark,
       ROUND(100.0 * SUM(MAX(li.freight_value - lb.lane_median, 0))
                   / SUM(li.freight_value), 1)                    AS pct_addressable
FROM lane_items li
JOIN lane_benchmark lb ON lb.lane = li.lane;
