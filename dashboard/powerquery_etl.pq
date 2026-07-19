// Power Query (M) ETL — Logistics KPI Dashboard
// Paste each query into Power BI Desktop: Home > Transform Data > New Source > Blank Query > Advanced Editor.
// Set DataFolder to the local path holding the Olist CSVs.

// ── Parameter ─────────────────────────────────────────────
// DataFolder (Text) = "C:\...\cost-to-serve-analytics\data"

// ── Query: Orders ─────────────────────────────────────────
let
    Source = Csv.Document(File.Contents(DataFolder & "\olist_orders_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(Promoted, {
        {"order_id", type text}, {"customer_id", type text}, {"order_status", type text},
        {"order_purchase_timestamp", type datetime}, {"order_delivered_customer_date", type datetime},
        {"order_estimated_delivery_date", type datetime}}),
    Delivered = Table.SelectRows(Typed, each [order_status] = "delivered" and [order_delivered_customer_date] <> null),
    AddDeliveryDays = Table.AddColumn(Delivered, "DeliveryDays",
        each Duration.Days([order_delivered_customer_date] - [order_purchase_timestamp]), Int64.Type),
    Clean = Table.SelectRows(AddDeliveryDays, each [DeliveryDays] >= 0 and [DeliveryDays] <= 60),
    AddOnTime = Table.AddColumn(Clean, "IsOnTime",
        each if [order_delivered_customer_date] <= [order_estimated_delivery_date] then 1 else 0, Int64.Type),
    Final = Table.RemoveColumns(AddOnTime, {"order_approved_at", "order_delivered_carrier_date"}, MissingField.Ignore)
in
    Final

// ── Query: OrderItems (fact table) ────────────────────────
let
    Source = Csv.Document(File.Contents(DataFolder & "\olist_order_items_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(Promoted, {
        {"order_id", type text}, {"product_id", type text}, {"seller_id", type text},
        {"price", type number}, {"freight_value", type number}}),
    Final = Table.RemoveColumns(Typed, {"shipping_limit_date"}, MissingField.Ignore)
in
    Final

// ── Query: Customers ──────────────────────────────────────
let
    Source = Csv.Document(File.Contents(DataFolder & "\olist_customers_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Final = Table.TransformColumnTypes(Promoted, {{"customer_id", type text}, {"customer_state", type text}})
in
    Final

// ── Query: Sellers ────────────────────────────────────────
let
    Source = Csv.Document(File.Contents(DataFolder & "\olist_sellers_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Final = Table.TransformColumnTypes(Promoted, {{"seller_id", type text}, {"seller_state", type text}})
in
    Final

// ── Query: Products (with English category names) ─────────
let
    Source = Csv.Document(File.Contents(DataFolder & "\olist_products_dataset.csv"), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Typed = Table.TransformColumnTypes(Promoted, {{"product_id", type text}, {"product_category_name", type text}, {"product_weight_g", type number}}),
    Translation = Table.PromoteHeaders(Csv.Document(File.Contents(DataFolder & "\product_category_name_translation.csv"), [Delimiter=",", Encoding=65001]), [PromoteAllScalars=true]),
    Merged = Table.NestedJoin(Typed, {"product_category_name"}, Translation, {"product_category_name"}, "T", JoinKind.LeftOuter),
    Expanded = Table.ExpandTableColumn(Merged, "T", {"product_category_name_english"}, {"category"}),
    Final = Table.SelectColumns(Expanded, {"product_id", "category", "product_weight_g"})
in
    Final

// ── Query: Dates (mark as date table, relate to Orders[order_purchase_timestamp]) ──
let
    Start = #date(2016, 9, 1),
    End = #date(2018, 10, 31),
    Dates = List.Dates(Start, Duration.Days(End - Start) + 1, #duration(1,0,0,0)),
    T = Table.FromList(Dates, Splitter.SplitByNothing(), {"Date"}),
    Typed = Table.TransformColumnTypes(T, {{"Date", type date}}),
    AddMonth = Table.AddColumn(Typed, "YearMonth", each Date.ToText([Date], "yyyy-MM"), type text)
in
    AddMonth
