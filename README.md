# Customer Revenue & Segmentation Analysis
### SQL + Power BI | Business Intelligence Portfolio Project

---

## 📌 Project Overview

This project analyses a customer transaction dataset of **5,000+ records** across **1,000 customers** to uncover revenue drivers, identify high-value segments, and support strategic retention and marketing decisions.

The analysis answers key business questions:
- Which customers contribute the most revenue? (Pareto / 80-20 analysis)
- Which segments, regions, and products drive the most value?
- What is the repeat purchase behaviour across the customer base?
- Where are the discount leakage and margin optimisation opportunities?
- What seasonal trends exist in monthly revenue?

---

## 🗂️ Project Structure

```
customer-revenue-segmentation/
│
├── README.md
├── data/
│   └── customer_revenue_analysis.xlsx        ← Dataset (5,000 transactions)
├── sql/
│   ├── 01_data_exploration.sql
│   ├── 02_pareto_analysis.sql
│   ├── 03_segment_region_analysis.sql
│   ├── 04_monthly_trends.sql
│   └── 05_retention_and_discounts.sql
├── insights/
│   └── key_findings.md
└── powerbi/
    └── customer_dashboard.pbix
```

---

## 📊 Dataset Description

| Field | Description |
|---|---|
| `Transaction_ID` | Unique ID per transaction |
| `Customer_ID` | Unique customer identifier |
| `Segment` | Enterprise / Mid-Market / SMB / Startup |
| `Region` | North / South / East / West / Central |
| `Industry` | Technology, Finance, Healthcare, Retail, etc. |
| `Channel` | Direct Sales / Online / Partner / Referral |
| `Product` | Product A–E |
| `Transaction_Date` | Date of transaction (2023–2024) |
| `Revenue` | Gross revenue per transaction |
| `Discount_Pct` | Discount applied (0–25%) |
| `Net_Revenue` | Revenue after discount |
| `Units_Sold` | Number of units per transaction |
| `Is_Repeat_Customer` | 1 = returning customer, 0 = new |
| `Customer_Since_Year` | Year the customer first joined |
| `Support_Tickets` | Number of support tickets raised |

---

## 🔑 Key Findings

| # | Finding |
|---|---|
| 1 | **Top 20% of customers contribute ~78% of total revenue** — strong Pareto effect |
| 2 | **Enterprise segment** drives the highest revenue despite being only ~10% of customers |
| 3 | **65% of transactions** are from repeat customers — strong base loyalty |
| 4 | Average discount is ~12.5% applied equally across all tiers — margin leakage opportunity |
| 5 | Revenue peaks in **Q4** across both 2023 and 2024 — seasonal marketing opportunity |
| 6 | **Partner and Referral channels** produce higher average transaction values than Direct Sales |

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| SQL (PostgreSQL) | Data exploration, aggregation, segmentation queries |
| Power BI | Interactive dashboard with 8+ KPIs |
| Excel | Raw dataset storage and KPI reference tables |
| GitHub | Version control and portfolio presentation |

---

## 📈 Power BI Dashboard — KPIs Tracked

1. Total Net Revenue  
2. Unique Active Customers  
3. Average Transaction Value  
4. Top 20% Customer Revenue Share (%)  
5. Repeat Customer Rate (%)  
6. Revenue by Segment (Donut Chart)  
7. Monthly Revenue Trend 2023–2024 (Line Chart)  
8. Revenue by Region (Bar / Map)  
9. Pareto Curve — Cumulative Revenue % by Customer Rank  
10. Revenue by Product and Channel  

---

## 💡 Business Recommendations

**1. Prioritise Top 20% Customers for Retention**  
These ~200 customers account for ~78% of revenue. Dedicated account management and quarterly business reviews for this group would significantly reduce churn risk.

**2. Discount Policy Restructuring**  
High-value customers receive similar discounts to low-revenue customers. A tiered discount policy would improve overall margins without sacrificing acquisition.

**3. Re-engage Bottom 80% of Customers**  
Targeted upsell campaigns — especially around top-performing products — could shift more customers into mid-tier revenue bands.

**4. Double Down on Q4 Momentum**  
Revenue consistently peaks in Q4. Launching campaigns in Q3 to capture early demand would extend the revenue window.

**5. Invest in Partner and Referral Channels**  
These channels show higher average transaction values — increasing partner incentives could yield better ROI than direct sales spend.

---

## 🚀 How to Reproduce This Analysis

1. **Clone the repo**
   ```bash
   git clone https://github.com/yourusername/customer-revenue-segmentation.git
   ```

2. **Load data into your SQL database**  
   Import `data/customer_revenue_analysis.xlsx` into PostgreSQL as a table named `transactions`.

3. **Run SQL scripts** in order (01 → 05) using pgAdmin, DBeaver, or any SQL client.

4. **Open Power BI** → Load the Excel file → Open `customer_dashboard.pbix`.

---

## 👤 Author

**Priyanka More**  
Business Analyst | SQL · Power BI · Excel · Python  
[LinkedIn](https://www.linkedin.com/in/priyanka-more-a476021a6/) | [Portfolio](https://github.com/ThePriEdit)
