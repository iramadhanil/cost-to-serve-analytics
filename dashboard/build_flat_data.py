"""Build the two flat tables the Power BI dashboard (logistics_kpi.pbix) imports.
Reads the raw Olist CSVs from ../data/ and writes orders_flat.csv (order grain)
and items_flat.csv (item grain) into ./pbix_data/. Order-grain is used so KPI
measures (avg delivery days, on-time %) are not inflated by multi-item orders.
Run: python build_flat_data.py
"""
import pandas as pd, os
D = os.path.join(os.path.dirname(__file__), "..", "data")
OUT = os.path.join(os.path.dirname(__file__), "pbix_data"); os.makedirs(OUT, exist_ok=True)
orders = pd.read_csv(f"{D}/olist_orders_dataset.csv", parse_dates=["order_purchase_timestamp","order_delivered_customer_date","order_estimated_delivery_date"])
items  = pd.read_csv(f"{D}/olist_order_items_dataset.csv")
cust   = pd.read_csv(f"{D}/olist_customers_dataset.csv")[["customer_id","customer_state"]]
sell   = pd.read_csv(f"{D}/olist_sellers_dataset.csv")[["seller_id","seller_state"]]
prod   = pd.read_csv(f"{D}/olist_products_dataset.csv")[["product_id","product_category_name","product_weight_g"]]
tr     = pd.read_csv(f"{D}/product_category_name_translation.csv")
od = orders[(orders.order_status=="delivered") & orders.order_delivered_customer_date.notna()].copy()
od["delivery_days"] = (od.order_delivered_customer_date - od.order_purchase_timestamp).dt.days
od["is_on_time"]    = (od.order_delivered_customer_date <= od.order_estimated_delivery_date).astype(int)
od = od[(od.delivery_days>=0) & (od.delivery_days<=60)]
it = (items.merge(od[["order_id","customer_id","order_purchase_timestamp","delivery_days","is_on_time"]], on="order_id")
            .merge(cust,on="customer_id",how="left").merge(sell,on="seller_id",how="left")
            .merge(prod,on="product_id",how="left").merge(tr,on="product_category_name",how="left"))
it["category"] = it["product_category_name_english"].fillna(it["product_category_name"]).fillna("unknown")
og = it.groupby("order_id").agg(gmv=("price","sum"), freight=("freight_value","sum"),
        purchase=("order_purchase_timestamp","first"), delivery_days=("delivery_days","first"),
        is_on_time=("is_on_time","first"), customer_state=("customer_state","first"),
        seller_state=("seller_state", lambda s: s.mode().iat[0] if len(s.mode()) else s.iloc[0])).reset_index()
og["year_month"] = og["purchase"].dt.strftime("%Y-%m"); og["purchase_date"] = og["purchase"].dt.date
og[["order_id","purchase_date","year_month","gmv","freight","delivery_days","is_on_time","customer_state","seller_state"]].to_csv(f"{OUT}/orders_flat.csv", index=False)
it["lane"] = it.seller_state.astype(str)+" -> "+it.customer_state.astype(str)
it["is_interstate"] = (it.seller_state!=it.customer_state).astype(int)
it[["order_id","seller_state","customer_state","lane","is_interstate","category","price","freight_value","product_weight_g"]].to_csv(f"{OUT}/items_flat.csv", index=False)
print(f"orders_flat: {len(og):,} rows | items_flat: {len(it):,} rows")
