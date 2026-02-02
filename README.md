# 📊 Online Retail Data Analysis (SQL)
## 📌 Project Overview

This project analyzes an online retail transaction dataset using SQL to uncover insights into sales performance, customer behavior, product trends, and retention patterns. The analysis is designed to simulate real-world business questions faced by e-commerce and retail analytics teams.

---

## 🗃 Dataset

- Online retail transaction data

- Key fields: invoice_num, invoice_date, customer_id, stock_code, description, quantity, unit_price, country

- Data was pre-cleaned to remove invalid transactions and standardize date formats

---

## 🎯 Business Questions Answered

- How does revenue trend over time and across countries?

- Which products generate the most sales and revenue?

- Who are the most valuable customers?

- How do customer purchasing patterns differ over time?

- What is customer retention by cohort?

- What does a typical shopping basket look like?

---

## 🧠 Key Analyses Performed

- Sales Performance Analysis

  - Total revenue

  - Monthly and country-level revenue trends

- Product Analysis

  - Best-selling products by quantity and revenue

  - Product profitability matrix

- Customer Behavior

  - Top customers by revenue

  - Purchase frequency analysis

  - RFM (Recency, Frequency, Monetary) segmentation using window functions

- Cohort Analysis

  - Customer retention by first purchase month

- Basket Analysis

  - Average basket size per transaction

- Time Series Analysis

  - Daily sales trends

  - Day-of-week seasonality

- Analytics View

  - Created a SQL view (onlineretail_summary) for dashboard-ready analytics
 
---

## 🛠 SQL Skills Demonstrated

- Aggregations & grouping

- Date transformation & time-series analysis

- Common Table Expressions (CTEs)

- Window functions (NTILE)

- Cohort & RFM analysis

- Business-driven analytical thinking

---

## 📈 Tools Used

- SQL (MySQL-style syntax)

---

## 📌 Notes & Assumptions

- Revenue calculated as quantity × unit_price

- Dates converted from string to date format

- Analysis focuses on completed sales transactions

---

## 🚀 Next Steps (Optional Enhancements)

- Visualization in Power BI / Tableau

- Customer lifetime value (CLV) modeling


