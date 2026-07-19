"""Load Olist CSVs (./data/*.csv) into SQLite (olist.db). Requires: pip install pandas"""
import sqlite3, glob, os
import pandas as pd

DB = "olist.db"
if os.path.exists(DB):
    os.remove(DB)
con = sqlite3.connect(DB)

for path in glob.glob("data/*.csv"):
    table = os.path.basename(path).replace("_dataset.csv", "").replace(".csv", "")
    df = pd.read_csv(path)
    df.to_sql(table, con, index=False)
    print(f"loaded {table}: {len(df):,} rows")

con.execute("CREATE INDEX idx_items_order ON olist_order_items(order_id)")
con.execute("CREATE INDEX idx_orders_customer ON olist_orders(customer_id)")
con.commit()
con.close()
print("done -> olist.db")
