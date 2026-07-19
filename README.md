# Cost-to-Serve Teardown — Brazilian E-Commerce (Olist, ~100k orders)

**Author:** Ichwan Ramadhanil · Cost Planning Engineer, Hino Motors (Toyota Group)
**Stack:** SQL (SQLite) · Python (loader) · Power BI (dashboard — see `/dashboard`)
**Goal:** Decompose delivery-cost drivers in a real e-commerce logistics dataset and quantify the top-3 cost levers — the same variance-analysis workflow I run on truck platform costs at Hino, applied to cost-to-serve.

## Dataset
[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 99,441 real orders / 112,650 order items (2016–2018) with freight values, product weights/categories, customer and seller locations, and delivery timestamps.

## Headline results (computed from the full dataset — see `/results`)

| Metric | Value |
|---|---|
| Delivered orders analyzed | 96,478 |
| GMV | R$13.22M |
| Total freight | R$2.20M — **16.6% of GMV** |
| Avg freight per order | R$22.79 |
| Freight burden, cheapest-basket decile | **98.3% of basket value** (avg basket R$29) vs 5.1% for the largest baskets |

## The top-3 cost levers, quantified

**Lever 1 — Interstate lane concentration (75.6% of freight spend).**
70,331 interstate shipments average **R$23.63** vs **R$13.45** intrastate — a **+76% premium** on three-quarters of total spend. The slowest delivery quartile (avg 23.8 days) also pays **R$28.16** avg freight vs R$16.55 in the fastest (4.5 days): long lanes are slow *and* expensive, so regionalization/consolidation improves cost and customer experience simultaneously.

**Lever 2 — Light, low-price categories with broken freight economics.**
Electronics and telephony items carry freight equal to **68.4%** and **50.8% of item price** (vs ~31% network average) at R$75–84 freight per kg — pricing/packaging/regional-stocking candidates. The worst freight-to-price decile of categories alone accounts for 5.9% of network freight.

**Lever 3 — Split shipments cost 2.1x.**
Orders fulfilled by multiple sellers ship separately and average **R$46.67 freight vs R$22.47** for single-shipment orders. Consolidating them cuts ~R$24/order on the affected volume.

**Supplier lens (analysis 07) — 22.5% of freight spend is above benchmark.**
Benchmarking every seller against the **median freight of their own lane** ("should-cost") shows **R$494k of R$2.2M** paid above lane median; the top seller-lane pair alone carries a R$7.5k gap. This is the negotiation agenda a purchasing team would run.

## Analysis structure
| # | Question | SQL techniques |
|---|----------|----------------|
| 01 | Is the data trustworthy? (row counts, nulls, duplicates) | aggregates, GROUP BY/HAVING |
| 02 | Baseline freight % of GMV + distribution | CTEs, NTILE() deciles |
| 03 | Which shipping lanes drive cost? | joins, CTEs, RANK() window |
| 04 | Which categories have the worst freight economics? | multi-join, NTILE() |
| 05 | Do customers pay more for slower delivery? | CTEs, NTILE(), date math |
| 06 | Top-3 cost levers, quantified | everything combined |
| 07 | Supplier should-cost benchmarking (purchasing view) | window-function medians, temp tables |

## How to run
```bash
# 1. Download the dataset from Kaggle and unzip all CSVs into ./data/
python load_data.py                       # creates olist.db
for f in sql/0*.sql; do sqlite3 olist.db < "$f"; done
```
Computed outputs are committed under `/results` (monthly KPIs, lane summary, category summary, full query results) so findings are reproducible and inspectable without rerunning.

## Dashboard (`/dashboard`)
Power BI logistics KPI dashboard on the same data: Power Query ETL script (`powerquery_etl.pq`), DAX measure definitions (`dax_measures.dax`), and build spec. KPIs: Freight % of GMV, Avg Freight/Order, Avg Delivery Days, On-Time %, with lane and category drill-downs — designed as a weekly operational review.

## Why this project
At Hino I decompose product cost into design, procurement and production drivers to hit platform target costs. This project applies the identical method — baseline → segmentation → root cause → quantified countermeasures — to e-commerce cost-to-serve (the core work of Amazon-style transformation/planning teams), and analysis 07 applies the supplier-benchmarking half of that method (should-cost, gap-to-benchmark, negotiation targets), which is the daily language of automotive purchasing.
