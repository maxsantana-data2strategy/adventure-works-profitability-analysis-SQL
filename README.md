## Territorial Profitability Analysis — Adventure Works

## 🔍 Overview

SQL-driven analysis of Adventure Works' territorial profitability across 6 markets. Calculated revenue, costs, and marketing ROI by country using JOINs and aggregations. Identified USA as top performer (75.8% ROI) and UK as underperformer (22.1% ROI), recommending budget reallocation for ~30–40% improvement.

## 🎯 Problem Statement

**Business Question:** Where should Adventure Works allocate the next marketing dollar to maximize ROI across global territories?

The CFO needed a data-driven answer: Which markets are generating the most revenue? Which are the most profitable after accounting for marketing spend? Which territories are underperforming despite high investment?

---

## 💡 What I Did

### Phase 1: Schema Exploration & Data Integration
- Mapped 6 relational tables (`ventas_2017`, `productos`, `productos_categorias`, `territorios`, `campanas`, `clientes`)
- Identified join keys: `clave_producto`, `clave_territorio`, `clave_subcategoria`
- Validated data integrity: 0 invalid prices, no unexpected nulls in critical fields

### Phase 2: Data Extraction & Cleaning
Built a unified `ventas_clean` table combining:
- Sales transactions (order ID, product, quantity, price, cost)
- Product hierarchy (category, subcategory)
- Geographic mapping (country, continent, territory)

**Calculated columns:**
- `ingreso_total` = precio_producto × cantidad_pedido
- `costo_total` = costo_producto × cantidad_pedido

**Data quality checks:**
- Handled NULLs with COALESCE (defaulting to 0 for financial fields)
- Validated no negative prices or quantities
- Cross-checked row counts across joins

### Phase 3: Financial KPI Calculation
Aggregated metrics by territory:
1. **Total Revenue & COGS** — summed by country
2. **Gross Profit** = Revenue − Direct Costs
3. **Margin %** = (Revenue − Costs) / Revenue × 100
4. **Marketing Spend** — joined from `campanas` table
5. **ROI %** = Gross Profit / Marketing Spend × 100

### Phase 4: Validation & Quality Assurance
- ✅ **Sum consistency:** Total ingresos and costos reconciled to source tables
- ✅ **Aggregation integrity:** Country totals = sum of all line items
- ✅ **Anomaly detection:** All margin % values within logical range (41.7%–44.8%)
- ✅ **Data completeness:** 0 invalid prices, no duplicate orders, no unexpected NULLs

---

## 🛠️ Technologies Used

| Category | Tools |
|----------|-------|
| **SQL** | JOINs (LEFT, INNER), GROUP BY, aggregation functions, COALESCE, NULLIF, CAST |
| **Techniques** | Data validation, QA checks, sum reconciliation, anomaly detection |
| **Database** | Relational schema with 6 tables, ~100K+ transactional rows |
| **Output** | Aggregated financial tables by territory |

---

## 📊 Key Findings

### Revenue & Profitability Snapshot
| Country | Revenue | Gross Profit | Margin % | ROI % |
|---------|---------|--------------|----------|-------|
| 🇺🇸 **USA** | $3.35M | $1.45M | **43.4%** | **75.8%** ⭐ |
| 🇦🇺 **Australia** | $2.53M | $1.06M | 41.7% | **49.2%** |
| 🇬🇧 **UK** | $1.19M | $0.51M | 42.7% | **22.1%** 🔴 |
| 🇩🇪 **Germany** | $1.07M | $0.46M | 42.9% | **20.3%** |
| 🇫🇷 **France** | $0.92M | $0.40M | 42.9% | **17.9%** |
| 🇨🇦 **Canada** | $0.71M | $0.32M | 44.8% | **17.4%** |

### Context → Findings → Implications (C→F→I)

**📍 Context:**
Adventure Works operates in 6 territories across North America, Europe, and Pacific regions, investing heavily in marketing campaigns (total: $12.7M) while managing direct product costs (COGS: $5.9M).

**🔍 Findings:**
1. **USA dominates in ROI:** 75.8% return on $1.92M marketing spend — exceptional efficiency
2. **Australia punches above weight:** Only $0.91M smaller revenue than USA, but 49.2% ROI shows strong market efficiency
3. **UK underperforms despite size:** $1.19M revenue generates only 22.1% ROI, indicating $2.3M marketing spend is not yielding proportional returns
4. **European markets lag:** Germany, France, and Canada cluster at 17–20% ROI — lowest performers
5. **Margin consistency:** All territories maintain 41.7–44.8% gross margin (healthy), but ROI divergence is entirely driven by **marketing spend efficiency**

**💡 Implications:**
- ✅ **Invest more in USA & Australia:** These territories prove high ROI — every incremental marketing dollar yields 50–76% return
- 🔄 **Optimize UK spend:** Reduce marketing budget or restructure campaigns; current $2.3M investment generates weakest ROI
- 📊 **Review European strategy:** France, Germany, Canada cluster below 21% ROI — investigate pricing, product mix, or campaign messaging
- 🎯 **Recommendation:** Reallocate ~$500K from underperforming UK/European territories to USA/Australia for estimated 30–40% improvement in blended ROI

---

## 📁 Project Files

```
├── queries/
│   └── SQL-queries-adventureworks.sql
├── outputs/
│   ├── Financial_Performance_Analysis_with_SQL_EN     # Final Excel results report
│   ├── Análisis del desempeño financiero con SQL      # Original results report
│   └── validation_report.txt                          # QA checks & reconciliation
└── README.md                                          # This file
```

---

## 🚀 How to Use

1. **Load Adventure Works dataset** into your database
2. **Run queries in order** (01 → 04) to build and validate the analysis
3. **Review outputs:** `kpi_by_territory.csv` contains the final decision-ready metrics
4. **Apply findings:** Use C→F→I recommendations to guide marketing budget allocation

---

## 📚 Learnings & Best Practices

- **Data validation is non-negotiable:** The 4-step QA process caught potential issues before they reached the CFO
- **JOINs + aggregation + business logic = insight:** Raw data means nothing; calculated KPIs drive decisions
- **COALESCE & NULLIF prevent silent errors:** Handling edge cases (0 marketing spend) prevents division errors and NaN results
- **Margin % is universal; ROI % is context-specific:** Both matter, but ROI directly answers the CFO's "where to invest" question
- **Always reconcile totals:** A simple SUM check against source tables prevented $XXK in reporting error



---

**Status:** ✅ Complete | **Data Quality:** ✅ Validated | **Ready for Decisions:** ✅ Yes
