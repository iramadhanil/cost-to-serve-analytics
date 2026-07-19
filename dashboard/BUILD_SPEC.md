# Logistics KPI Dashboard — Power BI Build Spec

**Goal:** a self-refreshing 2-page Power BI dashboard tracking delivery speed and cost-per-order KPIs on the same Olist dataset used in Project 1 — designed to look like a weekly operational review tool, because that is what Amazon STEP/LTP analysts actually build.
**Time budget:** ~3–4 hours in Power BI Desktop (free download). Do Project 1 first — this reuses its data.

## 1 · Data import (Power Query — this IS the "ETL" claim on your resume)
1. Get Data → Text/CSV → import from `Project_1_SQL_Cost_Teardown/data/`:
   `olist_orders`, `olist_order_items`, `olist_customers`, `olist_sellers`, `olist_products`.
2. In Power Query, per table: set data types, remove unused columns, filter `order_status = "delivered"`.
3. Add computed column on orders: `DeliveryDays = Duration.Days(order_delivered_customer_date - order_purchase_timestamp)`; filter 0–60.
4. Merge order_items ← products (product_id) to bring in category and weight.
5. Close & Apply. (Each of these steps is a recorded, refreshable transformation — that is your ETL pipeline.)

## 2 · Model (star schema)
- Fact: `olist_order_items` (grain: item).
- Dimensions: orders (dates, delivery), customers (state), sellers (state), products (category).
- Relationships: items→orders (order_id), orders→customers (customer_id), items→sellers (seller_id), items→products (product_id).
- Create a Date table: `Dates = CALENDAR(MIN(orders[order_purchase_timestamp]), MAX(...))`, mark as date table, relate to purchase date.

## 3 · DAX measures (create a `_Measures` table)
```dax
Total GMV            = SUM(olist_order_items[price])
Total Freight        = SUM(olist_order_items[freight_value])
Freight % of GMV     = DIVIDE([Total Freight], [Total GMV])
Orders               = DISTINCTCOUNT(olist_order_items[order_id])
Avg Freight / Order  = DIVIDE([Total Freight], [Orders])
Avg Delivery Days    = AVERAGE(olist_orders[DeliveryDays])
On-Time %            = DIVIDE(CALCULATE([Orders], olist_orders[order_delivered_customer_date] <= olist_orders[order_estimated_delivery_date]), [Orders])
Freight MoM %        = VAR prev = CALCULATE([Total Freight], DATEADD(Dates[Date], -1, MONTH)) RETURN DIVIDE([Total Freight] - prev, prev)
```

## 4 · Layout
**Page 1 — Network Overview:** 4 KPI cards (Freight % of GMV, Avg Freight/Order, Avg Delivery Days, On-Time %) · line chart Freight & GMV by month · map or bar of freight by customer state · slicers: month, state.
**Page 2 — Cost Drivers:** matrix of top lanes (seller state × customer state, values = Total Freight, Avg Freight/Order) · bar: freight-%-of-price by category (top 10 worst) · scatter: DeliveryDays vs Avg Freight by state (the "slow AND expensive" quadrant, top-right, is the story).

## 5 · Publish & link
1. File → Publish → Power BI Service (free account) → your workspace.
2. Screenshot both pages into the GitHub repo README (Project 1 repo, `/dashboard` folder + images).
3. Optional: File → Embed report → Publish to web → public link for the resume header. If Publish-to-web is unavailable on your tenant, the GitHub screenshots + .pbix file in the repo are enough.

## 6 · Interview talking points
- "I built the refresh pipeline in Power Query, so the dashboard is zero-touch on new data" → Invent and Simplify.
- "I chose Freight % of GMV as the headline KPI because absolute freight grows with sales; leaders need the ratio" → metric-design judgment (STEP JD: 'developing the right performance indicators').
- "The scatter shows speed and cost are correlated on long lanes — regionalization improves both" → ties directly to Amazon EU regionalization programs.
- Concepts transfer 1:1 to QuickSight (Amazon's internal BI tool) — say exactly that if asked why Power BI.

## GitHub repo structure (both projects, one repo is fine)
```
cost-to-serve-analytics/
├── README.md            (from Project 1, add dashboard screenshots section)
├── load_data.py
├── sql/01..06_*.sql
├── dashboard/
│   ├── logistics_kpi.pbix
│   ├── page1_overview.png
│   └── page2_cost_drivers.png
└── data/  (DO NOT commit the CSVs — add data/ to .gitignore, Kaggle licence)
```
Then put `github.com/<your-username>/cost-to-serve-analytics` in the resume header line of both TP resumes.
