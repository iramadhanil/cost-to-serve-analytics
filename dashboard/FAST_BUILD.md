# Power BI fast build — ~30 minutes

Goal: produce `logistics_kpi.pbix` + 2 screenshots. The full spec is in `BUILD_SPEC.md`;
this is the shortest honest path. The Olist CSVs are already in `../data/` locally.

## A · Data (10 min)
1. Open Power BI Desktop → **Get Data → Text/CSV** → import from `../data/`:
   `olist_orders`, `olist_order_items`, `olist_customers`, `olist_sellers`, `olist_products`, `product_category_name_translation`.
2. Instead of clicking transformations manually: **Transform Data → New Source → Blank Query → Advanced Editor**
   and paste each query from `powerquery_etl.pq` (6 queries, ready-made — set the `DataFolder` parameter first:
   Manage Parameters → New → Text → path to `data/`).
3. Close & Apply.

## B · Model (5 min)
Model view → drag relationships:
`OrderItems[order_id] → Orders[order_id]` · `Orders[customer_id] → Customers[customer_id]` ·
`OrderItems[seller_id] → Sellers[seller_id]` · `OrderItems[product_id] → Products[product_id]` ·
`Orders[order_purchase_timestamp] → Dates[Date]` (mark Dates as date table).

## C · Measures (5 min)
New table `_Measures`, then paste each measure from `dax_measures.dax`.

## D · Visuals (10 min)
**Page 1 — Network Overview:** 4 cards (Freight % of GMV · Avg Freight/Order · Avg Delivery Days · On-Time %),
line+column chart by `Dates[YearMonth]` (Freight % line, GMV bars), bar of Total Freight by `Customers[customer_state]`, slicer on YearMonth.
**Page 2 — Cost Drivers:** matrix `Sellers[seller_state]` x `Customers[customer_state]` (Total Freight),
bar of Freight % of Price by `Products[category]` (top 10), scatter Avg Delivery Days vs Avg Freight/Order by state.
Sanity check vs the live web dashboard (same numbers): https://iramadhanil.github.io/cost-to-serve-analytics/dashboard/
— headline KPIs must read **16.6% · R$22.79 · 12.6 · 91.9%**. If they don't, a relationship or filter is wrong.

## E · Ship (2 min)
Save `dashboard/logistics_kpi.pbix` → screenshot both pages as `page1_overview.png`, `page2_cost_drivers.png`
into `dashboard/` → commit & push. Done — the resume claim is now 100% backed.
