# Olist Customer Retention & Churn Driver Analysis

SQL + Power BI analysis of customer retention, repeat purchasing, and potential churn drivers using the Olist e-commerce dataset.

## 🎯 Business Question

Once a customer makes a purchase on Olist, do they come back — and if not, what factors might explain the low repeat-purchase rate?

## 🔍 Analysis Approach

- Built customer cohort retention logic in MySQL using CTEs.
- Tracked approximately 99K customers by their first-purchase month.
- Measured retention across months since the first purchase.
- Tested two potential churn drivers:
  - Delivery performance
  - Review score
- Built an interactive Power BI dashboard to explore cohort-level retention.

## 📊 Key Findings

- Customer retention drops sharply after the first purchase, with repeat purchasing falling to below 1% by around month 3 across most cohorts.
- Customers experiencing late delivery showed a **4.81% repeat rate**, compared with **3.33%** for on-time delivery customers.
- Customers with lower review scores showed a **4.72% repeat rate**, compared with **3.58%** for higher review scores.
- These results suggest that delivery performance and review score alone do not explain Olist's extremely low repeat-purchase behavior.
- The low retention appears to be largely structural, potentially influenced by Olist's product mix and the nature of one-time purchases.

Note: the review-score result is somewhat counterintuitive — this likely reflects that repeat buyers, having placed more orders, have more opportunities to receive any review score, including low ones, rather than bad reviews driving repeat behavior.

## 💡 Recommendations

- Do not treat delivery improvements as the primary retention strategy based solely on these results.
- Investigate cross-selling and product bundling to create additional purchase opportunities.
- Use post-purchase campaigns to encourage customers to return.
- Perform category-level retention analysis to identify product categories with naturally higher repeat-purchase potential.

## 📈 Power BI Dashboard

The dashboard includes:

- Cohort retention heatmap
- Retention trend visualization
- KPI cards
- Churn-driver comparison
- **Interactive cohort-month slicer** to explore retention patterns for individual cohorts

### Dashboard Preview

![Olist Customer Retention Dashboard](olistcustomer%20retention%20pic.png)

## 🛠️ Tools

- **MySQL** — SQL analysis, CTEs, cohort analysis and aggregation
- **Power BI** — Data visualization, dashboard development and interactive slicers
- **DAX** — Measures and KPI calculations

## 📁 Project Files

- `olist_customer_retention_analysis.sql` — SQL queries used for the analysis
- `dashboard_screenshot.png` — Power BI dashboard preview
- - Power BI `.pbix` file — hosted on Google Drive (link below)

## 📥 Power BI File

The `.pbix` file is hosted on Google Drive because of GitHub's file-size limitation.

**[Download the Power BI Dashboard (.pbix)](https://drive.google.com/file/d/1BoiZ5LYSiorno4EPq_WJayP_64GGwggg/view?usp=sharing)
