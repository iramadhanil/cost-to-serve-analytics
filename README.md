# Cost-to-Serve Teardown — Brazilian E-Commerce (Olist, 100k+ orders)

**Author:** Ichwan Ramadhanil · Cost Planning Engineer, Hino Motors (Toyota Group)
**Stack:** SQL (SQLite), Python (loader only)
**Goal:** Decompose delivery-cost drivers in a real e-commerce logistics dataset and identify the top-3 cost levers — the same variance-analysis workflow I run on truck platform costs at Hino, applied to cost-to-serve.

## Dataset
[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — ~100k real orders (2016–2018) with order items, freight values, product weights/categories, customer and seller locations, delivery timestamps. Free Kaggle account required.

## How to run
```bash
# 1. Download the dataset from Kaggle and unzip all CSVs into ./data/
# 2. Load into SQLite:
python load_data.py          # creates olist.db
# 3. Run the analyses in order:
sqlite3 olist.db < sql/01_data_quality.sql
sqlite3 olist.db < sql/02_freight_baseline.sql
sqlite3 olist.db < sql/03_cost_by_route.sql
sqlite3 olist.db < sql/04_cost_by_category.sql
sqlite3 olist.db < sql/05_speed_vs_cost.sql
sqlite3 olist.db < sql/06_top_cost_levers.sql
```

## Analysis structure
| # | Question | SQL techniques |
|---|----------|----------------|
| 01 | Is the data trustworthy? (row counts, nulls, duplicate orders) | aggregates, GROUP BY/HAVING |
| 02 | What is baseline freight cost as % of GMV, and its distribution? | CTEs, aggregate stats |
| 03 | Which shipping lanes (seller state → customer state) drive cost? | joins, CTEs, RANK() window |
| 04 | Which product categories have the worst freight-per-kg and freight-to-price ratio? | multi-join, NTILE() window |
| 05 | Do customers pay more freight for slower delivery? (cost vs speed quartiles) | CTEs, NTILE(), date math |
| 06 | Top-3 cost levers, quantified | everything combined |

## Findings (fill after running — template)
1. **Lever 1 — Long interstate lanes:** X% of orders ship on the top-10 costliest lanes at an average freight of R$X vs network average R$X → consolidation/regional-stocking opportunity worth ~X% of total freight spend.
2. **Lever 2 — Heavy, low-price categories:** categories in the worst freight-to-price decile (e.g., furniture, housewares) carry freight equal to X% of item price vs X% network median.
3. **Lever 3 — Single-item shipments:** X% of multi-item orders ship from multiple sellers separately; combined shipments would reduce per-order freight by ~X%.

## Why this project (interview talking point)
At Hino I decompose product cost into design, procurement and production drivers to hit platform target costs. This project applies the identical method — baseline → segmentation → root cause → quantified countermeasures — to e-commerce cost-to-serve, which is the core work of Amazon's EU Long Term Planning / Transformation Programs teams.
