# Full query results (run 20 Jul 2026, full Olist dataset)

## 01 · Data quality
- 112,650 order items; 0 null freight; 383 zero-freight items (0.34%)
- 0 duplicate orders; 96,478 delivered orders (8 missing delivery timestamp, excluded)

## 02 · Baseline
| delivered_orders | total_gmv | total_freight | freight_pct_of_gmv | avg_freight_per_order |
|---|---|---|---|---|
| 96,478 | R$13,221,498 | R$2,198,276 | 16.63% | R$22.79 |

Freight % of basket by basket-size decile (1 = largest baskets):
| decile | avg_basket | avg_freight_pct |
|---|---|---|
| 1 | R$454.1 | 5.1% |
| 5 | R$108.3 | 20.3% |
| 10 | R$29.4 | 98.3% |

## 03 · Lanes
Interstate vs intrastate:
| flow | shipments | avg_freight | share_of_freight |
|---|---|---|---|
| interstate | 70,331 | R$23.63 | 75.6% |
| intrastate | 39,866 | R$13.45 | 24.4% |

Top lanes by total freight: SP→SP R$467k (avg R$13.20) · SP→RJ R$192k (R$20.39) · SP→MG R$173k (R$20.25) · SP→RS R$85k · SP→PR R$74k. Highest avg-cost major lanes: SP→PE R$30.91, SP→CE R$30.95.

## 04 · Categories (worst freight-to-price)
| category | items | avg_freight | freight_per_kg | freight_pct_of_price |
|---|---|---|---|---|
| electronics | 2,729 | R$16.74 | R$74.84 | 68.4% |
| telephony | 4,430 | R$15.65 | R$83.98 | 50.8% |
| food_drink | 269 | R$16.34 | R$27.26 | 49.2% |
| construction_tools_garden | 232 | R$22.36 | R$29.93 | 41.8% |
| drinks | 361 | R$15.07 | R$40.98 | 41.5% |

## 05 · Speed vs cost (delivery-time quartiles)
| quartile | orders | avg_days | avg_freight |
|---|---|---|---|
| 1 (fastest) | 24,041 | 4.5 | R$16.55 |
| 2 | 24,041 | 8.4 | R$21.88 |
| 3 | 24,041 | 12.7 | R$24.45 |
| 4 (slowest) | 24,041 | 23.8 | R$28.16 |

## 06 · Levers
- L1: interstate = 75.6% of freight spend
- L2: worst-decile categories = 5.9% of freight spend
- L3: split (multi-seller) orders = 1.3% of orders, R$46.67 avg freight vs R$22.47 single (2.1x)

## 07 · Supplier benchmarking
- 22.5% of freight spend (R$493,608 of R$2,198,276) is above lane-median benchmark
- Top negotiation targets (≥50 shipments on lane, sorted by savings if brought to median):

| seller (truncated) | lane | shipments | seller_avg | lane_median | savings_at_median |
|---|---|---|---|---|---|
| 7c67e14... | SP→SP | 536 | R$25.82 | R$11.86 | R$7,481 |
| 7c67e14... | SP→RJ | 260 | R$42.13 | R$17.28 | R$6,460 |
| a1043ba... | MG→RJ | 201 | R$44.44 | R$18.02 | R$5,310 |
| a1043ba... | MG→SP | 118 | R$43.84 | R$16.74 | R$3,197 |
| 5dceca1... | SP→SP | 154 | R$31.50 | R$11.86 | R$3,024 |

Aggregate exports in this folder: `monthly_kpis.csv`, `lane_summary.csv`, `category_summary.csv`.
