# Northwind Business Analysis — SQL Server & Looker Studio

A portfolio case study turning Northwind's sample transactional data into business analysis and interactive reporting across sales, products, customers, shipping, and employee activity.

**Tools:** SQL Server · T-SQL · Looker Studio  
**Deliverables:** data-quality audit, business analysis scripts, six reporting views, and five dashboard pages.

**[Explore the interactive Looker Studio report](https://datastudio.google.com/s/gjPixVIulsE)**

## Project objective

Acting as a data analyst for the fictitious Northwind Traders company, this project investigates revenue drivers, customer purchasing patterns, product demand, shipment timing, and the distribution of sales activity across employees. It connects business questions to explicit KPI definitions, SQL transformations, and visual analysis.

The workflow runs from SQL analysis to dashboard reporting: **execute the SQL scripts → export the result sets → import the data into Looker Studio**. This is an analysis of a historical sample dataset, with proposed actions rather than measured business impact.

## Results at a glance

| Indicator | Revised dashboard |
| --- | ---: |
| Net revenue | Approximately $1.27 million |
| Orders | 830 |
| Countries served | 21 |
| Average order value | $1,525.05 |
| Discount rate | 6.55% |
| Customers with purchase history | 89 |
| Employees represented | 9 |

The sales trend covers July 1996 through April 1998 and explicitly excludes the incomplete May 1998 month. This exclusion applies to the trend chart; it should not be assumed to apply to every headline KPI.

### Five business findings

1. **Revenue is concentrated geographically.** The USA and Germany lead the country revenue ranking. High-value outliers account for **7.1% of orders** under the IQR classification. These views support a review of market concentration and large-order exposure; the remaining 92.9% in the typical range does not establish low variance or forecast accuracy.

2. **Product priorities differ by revenue and volume.** Côte de Blaye leads product net revenue at approximately **$141.4k**, while Camembert Pierrot leads units sold at approximately **1.6k units**. Beverages and Dairy Products generate approximately **$267.9k** and **$234.5k**, respectively—roughly **40% of revenue**, calculated from the rounded displayed amounts. This supports separate reviews of high-revenue products and high-volume replenishment needs, subject to stock and lead-time evidence.

3. **High-value customer inactivity provides a focused review list.** The revised segmentation shows **30 Champions / VIP customers (33.7%)** and **10 At Risk / High Value customers (11.2%)**. Mère Paillarde illustrates the latter group, with **$28,872.19** in historical net purchases and **188 days since its last order** at the dataset reference date. These accounts are candidates for contact-history review; inactivity is not confirmed churn.

4. **Shipment timing warrants operational investigation.** The dashboard reports **8.49 days** from order to shipment on average and a **4.57%** late-shipment rate. Orders assigned to Federal Shipping show **7.47 days** and **3.61%**, compared with **9.23 days** and **5.08%** for United Package. These differences support investigation of order mix and fulfillment processes, without establishing carrier responsibility or customer delivery performance.

5. **The revenue leader and the AOV leader are different employees.** Margaret Peacock manages **156 orders**, generating approximately **$232.9k** and **18.40%** of company net revenue. Anne Dodsworth has the highest displayed revenue per order at **$1,797.86**, across **43 orders**. These are complementary measures of sales activity; territory, account allocation, tenure, and targets are needed to assess individual performance fairly.

*Metrics were checked against SQL results and the five Looker Studio dashboard pages. Screenshots are available in `screenshots/`; monetary notation is normalized to English in this README.*

## Actionable recommendations (proposals, not measured outcomes)

- **Customer retention:** review the **10 At Risk / High Value customers**, validate whether the observed inactivity differs from their normal ordering cadence, and test targeted outreach only where justified.
- **Product planning:** separate **net-revenue leaders** from **high-unit-volume products** when prioritizing assortment and replenishment; current inventory fields are not historical stock data.
- **Shipping operations:** investigate the observed **order-to-shipment** differences across carriers and destinations before attributing the variation to a carrier or changing operational policy.

For the evidence, suggested pilot actions, monitoring KPIs and limits, see **[Business recommendations and decision plan (FR)](docs/RECOMMANDATIONS_METIER.md)**. No intervention or post-action performance improvement is claimed.

## Dashboard preview

The report contains five complementary business views. Expand each section to see the corresponding capture.

### Sales Performance

Revenue trend, country ranking, headline KPIs, and order-value classification.

![Sales Performance](screenshots/page1_sales.png)

<details>
<summary>Product Performance</summary>

Product revenue and volume rankings, category revenue, and monthly category volumes. May 1998 is excluded from the monthly volume trend. The monthly category-volume chart uses regular stacked columns (absolute units, not 100%-stacked), as shown in the updated screenshot below.

![Product Catalogue Analysis](screenshots/page2_products.png)

</details>

<details>
<summary>Logistics & Shipping</summary>

Order-to-shipment lead times, shipment timing, and recorded freight amounts by carrier and destination.

![Logistics and Shipping Performance](screenshots/page3_logistics.png)

</details>

<details>
<summary>Customer Analysis</summary>

Customer purchase history, RFM segmentation, and segment distribution by customer country.

![Customer 360 Analysis](screenshots/page4_customers.png)

</details>

<details>
<summary>Employee Performance</summary>

Employee revenue, order counts, revenue contribution, average order value, and revenue by role.

![Employee Performance Analysis](screenshots/page5_employees.png)

</details>

## SQL analysis and repository structure

The analysis follows the CQNARD sequence: Context, Questions, data quality and preparation, Analysis, Results, and Decisions.

| File | Analytical purpose |
| --- | --- |
| `SQL/01_data_cleaning.sql` | Non-destructive quality audit: financial fields, missing references, dates, pending orders, and inventory snapshot |
| `SQL/02_sales_analysis.sql` | Monthly revenue, growth, cumulative revenue, and first-observed customer orders |
| `SQL/03_customer_analysis.sql` | Customer value, RFM segmentation, inactivity monitoring, and regional basket comparisons |
| `SQL/04_product_analysis.sql` | Product/category rankings, revenue versus volume profiles, discount exposure, and inventory snapshot |
| `SQL/05_logistics_analysis.sql` | Shipment timing, lead times, freight amounts, and carrier/destination comparisons |
| `SQL/06_employee_analysis.sql` | Employee metrics, revenue contribution, and customer-geography footprint |
| `SQL/07_kpi_views.sql` | Six reporting views using conditional creation followed by `ALTER VIEW`, plus reconciliation queries |
| `screenshots/` | Five dashboard captures referenced by this README |
| [Northwind_ER_A4.pdf](Northwind_ER_A4.pdf) | Database relationship diagram |
| `README.md` | Project objectives, results, metric definitions, and reproduction notes |
| `SQL/09_controles_reproductibilite.sql` | Read-only verification of tables, constraints, views, and revenue |
| `SQL/10_exports_looker_studio.sql` | Six SELECTs to export reporting datasets to CSV |
| `docs/` | Source provenance, full setup procedure, and BI-source mapping |

The `SQL/` folder contains seven core analysis scripts (`01`–`07`) and three supporting scripts (`08`–`10`) for environment verification, reproducibility checks, and Looker Studio exports. `SQL/07_kpi_views.sql` includes view deployment and reconciliation queries. SQL analysis also includes outputs beyond those displayed in the dashboard.

## Metric definitions and reporting model

### Revenue and order value

Calculations use transaction-time fields from `[Order Details]`, rather than current prices from `Products`:

```text
Gross revenue   = SUM(Quantity × UnitPrice)
Discount amount = SUM(Quantity × UnitPrice × Discount)
Net revenue     = SUM(Quantity × UnitPrice × (1 − Discount))
Discount rate   = Discount amount / Gross revenue
AOV             = Net revenue / Distinct orders
```

Financial inputs are cast to `DECIMAL`, with rounding generally applied at presentation time. Freight is separate from product net revenue. These measures do not establish profit or margin.

Order lines are aggregated to orders before calculating customer and employee metrics. Overall AOV uses total revenue divided by total orders, rather than an average of country or employee AOVs. Counts of orders containing a product or category are not additive across products or categories.

### Customer segmentation and shipment timing

**RFM:** recency is measured against the latest order date in the dataset, frequency counts distinct orders with detail records, and monetary value sums net purchases. `PERCENT_RANK()` produces relative scores from 1 to 4 while preserving ties. Champions have R, F, and M scores of at least 3; At Risk / High Value customers have R ≤ 2 and F and M ≥ 3. The separate 90-day inactivity query is a different monitoring rule. The 89 customers represented have purchase history; the figure is not a count of every customer record.

**Shipping:** lead time is the day difference between `OrderDate` and `ShippedDate`. The view retains valid shipped orders with shipper records. A late shipment satisfies `ShippedDate > RequiredDate`; missing required dates are excluded from the rate denominator. Pending orders are audited separately. `ShippedDate` is not a delivery date. The dashboard's freight figures represent recorded order amounts, whose accounting treatment is not established by the dataset.

### Six reporting views

| View | Row grain |
| --- | --- |
| `v_bi_regional_turnover_update` | Shipping country |
| `v_bi_order_value_outliers` | Order with order-detail records |
| `v_bi_product_performance_by_region` | Product × shipping country × order month |
| `v_bi_shipping_performance` | Valid shipped order with a shipper record |
| `v_bi_customer_360` | Customer with purchase history |
| `v_bi_employee_performance` | Employee with order-detail-backed sales activity |

Sales and shipping use `ShipCountry`; customer analysis uses `Customers.Country`. IQR thresholds and employee contribution denominators are computed over their full SQL source populations. Product ranks apply within each country-month, not globally. Dashboard filters do not automatically recompute these definitions.

## Reproduce the analysis

**[Step-by-step setup and validation guide (FR)](docs/REPRODUCTION.md)** · **[Source provenance (FR)](docs/SOURCES_ET_PROVENANCE.md)** · **[SQL → Looker Studio mapping (FR)](docs/MAPPING_LOOKER_STUDIO.md)** · **[Business recommendations (FR)](docs/RECOMMANDATIONS_METIER.md)**

1. Use a dedicated **`Northwind` SQL Server database**. On a **fresh, separate test instance**, obtain the official [`instnwnd.sql` from Microsoft](https://github.com/microsoft/sql-server-samples/blob/master/samples/databases/northwind-pubs/instnwnd.sql) and load it into an **empty** `Northwind` database. **Do not run the official script on an existing database**: it contains destructive object-recreation commands. On the existing project installation, **skip this step**.
2. Run `SQL/01_data_cleaning.sql` through `SQL/06_employee_analysis.sql`, then `SQL/07_kpi_views.sql` to create/update the six reporting views. Each analysis script targets `USE [Northwind];`. The DBeaver/JDBC-compatible view script uses `EXEC(N'...')` instead of `GO`.
3. Run the read-only `SQL/09_controles_reproductibilite.sql` to check source counts, referential constraints, reporting-view row counts, and the **$1,265,793.04** reconciled net revenue (with the documented rounding convention).
4. Run `SQL/10_exports_looker_studio.sql` and export each BI view to a complete, headered UTF-8 CSV. Build the five Looker Studio pages using the six mapped data sources and validate chart scopes and KPI definitions against the reference screenshots.

**Reproduction status:** SQL execution and targeted controls were verified on the existing SQL Server installation in October 2026. A fully independent rebuild and an identical reconstruction of Looker Studio sources and calculated fields have **not** yet been verified. The original download URL could not be recovered; a locally retained `instnwnd.sql` was identical by SHA-256 to Microsoft's hosted script when compared on 11 October 2026. **The Microsoft dataset-installation script is not redistributed here.**

## Analytical limits and reconciliation

- **Financial precision (verified in SQL Server, October 2026):** six independent reporting aggregations, together with the order-detail baseline, reconcile to **$1,265,793.0395 before display rounding** (**$1,265,793.04** at two decimals), using `CAST(Discount AS DECIMAL(18,4))`. The **$1,265,793.05** obtained by summing already-rounded employee amounts differs by **$0.01** because rounding before summation is not equivalent to rounding the final sum. The formerly hard-coded **$1,265,793.22** product reference was obsolete; `SQL/04_product_analysis.sql` now recalculates the baseline directly from order details. These checks do not independently certify the source data or the Looker Studio export configuration.
- **Time coverage:** monthly SQL queries infer the final incomplete month from the latest order date. BI views retain all available months, so trend exclusions must be applied in reporting. First-month coverage and missing months also need consideration when interpreting growth; the short history does not establish recurring seasonality.
- **Causality and scope:** discount comparisons do not estimate promotional effects or price elasticity. Inventory fields are a snapshot, not historical stock records. Shipment timing differences and employee sales rankings need operational context before business action.

## Skills demonstrated

T-SQL joins and CTEs; window functions (`LAG`, `RANK`, `PERCENT_RANK`, `PERCENTILE_CONT`, cumulative sums); quality auditing; transaction-level financial calculations; RFM segmentation; IQR classification; reporting-view design; aggregation-grain management; dashboard design; and evidence-based business interpretation.
