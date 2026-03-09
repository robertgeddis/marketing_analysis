# Spend Attribution 

## 📌 Overview
A collection of SQL queries for attributing marketing spend, calculating spend based metrics (CAC, LTV) and building dashboards.
The goal of the work in this repository was to provide a 'single source of truth' regarding spend and turn raw data to actionable insights.

## 💼 Business Value & Impact
In my previous role, these queries were instrumental in:
* **Budgeting:** Segmenting spend by country, marketing channel, user role and vertical.  
* **CPA Analysis:** Consolidating data from APIs with manual csv files along with internal conversion data to calculate Cost Per Acquisition.
* **Optimization:** Identifying underperforming channels where spend did not correlate with high-quality user acquisition.

## 🛠 Technical Features (SQL)
To ensure data accuracy and performance, these scripts utilize:
* **Common Table Expressions (CTEs):** For modular, readable code that separates data cleaning from final aggregation.
* **Window Functions:** (e.g., `SUM() OVER(...)`) to calculate cumulative spend and running totals across time periods.
* **Complex Joins:** Bridging disparate data sources such as manual spend files with transactional databases.
* **Data Normalization:** Handling currency conversions and aligning spend to user and vertical matrix for reporting.

## 📊 Sample Metrics Calculated
* **CAC (Customer Acquisition Cost):** Total Spend / New Upgrades.
* **ROAS (Return on Ad Spend):** Total Revenue / Total Spend.
* **LTV:** Bookings / Churn 
