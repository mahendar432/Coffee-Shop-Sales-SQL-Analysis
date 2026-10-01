# ☕ Coffee Shop Sales Analysis using SQL

![MySQL](https://img.shields.io/badge/Database-MySQL-blue)
![SQL](https://img.shields.io/badge/Language-SQL-orange)
![Data Analysis](https://img.shields.io/badge/Project-Data%20Analysis-green)
![Status](https://img.shields.io/badge/Status-Completed-success)

## 📌 Project Overview

This project analyzes **Coffee Shop Sales data using MySQL** to understand sales performance, order trends, product performance, store-level performance, and time-based sales patterns.

The project follows an end-to-end SQL data analysis workflow:

**Raw Data → Data Cleaning → Data Validation → Transformation → KPI Analysis → Trend Analysis → Business Insights**

The analysis focuses on monthly sales performance, Month-over-Month (MoM) changes, orders, quantity sold, store locations, product categories, top-selling products, weekdays/weekends, and sales by day and hour.

---

## 🎯 Business Objective

The objective of this project is to use SQL to answer important business questions such as:

- How much did the coffee shop sell each month?
- How did sales change compared with the previous month?
- How many orders were generated each month?
- How many products were sold?
- Which store location generated the highest sales?
- Which product categories contributed the most to sales?
- What are the top 10 products by sales?
- Do weekdays and weekends show different sales patterns?
- Which days and hours generate higher sales?
- Which days performed above or below the average daily sales?

---

# 📊 KPI Requirements

## 1. Total Sales Analysis

### KPIs

- Total Sales
- Month-over-Month (MoM) Sales Change
- MoM Sales Percentage Change
- Difference between Current Month and Previous Month Sales

### SQL Approach

Sales were calculated using:

```sql
SUM(unit_price * transaction_qty)
```
Monthly sales were then compared using the LAG() window function.

## 2. Total Orders Analysis
KPIs
- Total Orders
- MoM Change in Orders
- MoM Percentage Change in Orders
- Difference between Current and Previous Month Orders
Orders were calculated using:
```sql
COUNT(transaction_id)
```
## 3. Total Quantity Sold Analysis
KPIs
- Total Quantity Sold
- MoM Quantity Change
- MoM Quantity Percentage Change
- Difference between Current and Previous Month Quantity
Quantity was calculated using:
```sql
SUM(transaction_qty)
```
## 🧹 Data Cleaning & Preparation
Before performing the analysis, the dataset was checked and prepared using SQL.
Step 1: Check Total Number of Records
```sql
SELECT COUNT(*) AS total_rows
FROM coffee;
```
This was used to verify the number of records in the dataset.

Step 2: Inspect Table Structure
```sql
DESCRIBE coffee;
```
This helped understand:
- Column names
- Data types
- Table structure

Step 3: Identify Date Format
The transaction date column was checked to understand the format of the existing values.
```sql
SELECT 
    CASE
        WHEN transaction_date LIKE '____-__-__' THEN 'YYYY-MM-DD'
        WHEN INSTR(transaction_date, '/') > 0 THEN 'M/D/YYYY'
        ELSE 'Other'
    END AS date_format,
    COUNT(*) AS total_rows
FROM coffee
GROUP BY date_format;
```
Step 4: Check Invalid Dates
```sql
SELECT COUNT(*) AS invalid_date
FROM coffee
WHERE STR_TO_DATE(transaction_date, '%c/%e/%Y') IS NULL;
```
This was used to identify invalid date values before conversion.

Step 5: Standardize the Date Values
The original date values were converted into a standardized date format.
```sql
UPDATE coffee
SET transaction_date =
    DATE_FORMAT(
        STR_TO_DATE(transaction_date, '%c/%e/%Y'),
        '%Y-%m-%d'
    );
```

Step 6: Convert Date Column to DATE
```sql
ALTER TABLE coffee
MODIFY COLUMN transaction_date DATE;
```
This changed the column data type from text/string to a proper MySQL DATE.

Step 7: Convert Transaction Time
```sql
ALTER TABLE coffee
MODIFY COLUMN transaction_time TIME;
```
This allowed time-based analysis using functions such as:
```sql
HOUR()
```
Step 8: Handle Column Naming Issues
The dataset contained a column-name formatting issue caused by an unwanted character in the transaction ID column.
The column was renamed and its definition was standardized.
```sql
ALTER TABLE coffee
CHANGE COLUMN transaction_id Transaction_id INT;
```
and finally:
```sql
ALTER TABLE coffee
CHANGE COLUMN Transaction_id transaction_id INT;
```
Step 9: Check NULL Values
NULL values were checked across the important columns.
```sql
SELECT
    SUM(transaction_id IS NULL) AS transaction_id_nulls,
    SUM(transaction_date IS NULL) AS transaction_date_nulls,
    SUM(transaction_time IS NULL) AS transaction_time_nulls,
    SUM(transaction_qty IS NULL) AS transaction_qty_nulls,
    SUM(store_id IS NULL) AS store_id_nulls,
    SUM(store_location IS NULL) AS store_location_nulls,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(unit_price IS NULL) AS unit_price_nulls,
    SUM(product_category IS NULL) AS product_category_nulls,
    SUM(product_type IS NULL) AS product_type_nulls,
    SUM(product_detail IS NULL) AS product_detail_nulls
FROM coffee;
```
This helped identify which columns required additional data-quality checks.
## 📈 SQL Analysis
Monthly Sales Analysis
Monthly sales were calculated using:
```sql
SUM(unit_price * transaction_qty)
```
The LAG() window function was used to compare the current month with the previous month.
MoM Formula
```sql
MoM % Change =
(Current Month Sales - Previous Month Sales)
------------------------------------------------ × 100
Previous Month Sales
```
This helps identify whether sales increased or decreased compared with the previous month.
## 📦 Monthly Order Analysis
Monthly orders were calculated using:
```sql
COUNT(transaction_id)
```
The LAG() function was used to compare the current month's orders with the previous month.
## 📊 Monthly Quantity Analysis
```sql
Total quantity sold was calculated using:
SUM(transaction_qty)
```
The same MoM approach was used to analyze changes in quantity sold.
## 📅 Calendar / Daily Sales Analysis
Daily sales metrics were prepared for calendar-based analysis.
The following KPIs were calculated for a selected date:
- Total Sales
- Total Orders
- Total Quantity Sold
Example:
```sql
SELECT
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1), 'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1), 'K') AS total_qty_sold
FROM coffee
WHERE transaction_date = '2023-03-27';
```

## 🗓️ Weekday vs Weekend Analysis
Sales were divided into:
- Weekdays → Monday to Friday
- Weekends → Saturday and Sunday
SQL function used:
```sql
DAYOFWEEK()
```
This analysis helps understand differences between weekday and weekend sales performance.
## 🏪 Store Location Analysis
Sales were analyzed across different store locations.
```sql
SELECT 
    store_location,
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee
WHERE MONTH(transaction_date) = 5
GROUP BY store_location
ORDER BY total_sales DESC;
```
This identifies store locations based on their sales contribution.
## 📅 Daily Sales Analysis
Daily sales were calculated using:
```sql
DAY(transaction_date)
```
The analysis provides:
- Daily sales
- Average daily sales
- Above-average sales days
- Below-average sales days
An average sales benchmark was calculated and individual days were classified as:
- Above Average
- Below Average
- Equal to Average
## ☕ Product Category Analysis
Sales were analyzed across product categories.
Example categories can be evaluated using:
```sql
GROUP BY product_category
```
The results help identify which product categories contribute the most to overall sales.
## 🏆 Top 10 Products by Sales
The top 10 products were identified using:
```sql
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;
```
This helps identify the products contributing the highest sales.
## ⏰ Sales by Day and Hour
Time-based analysis was performed using:
```sql
DAYOFWEEK(transaction_date)
```
and:
```sql
HOUR(transaction_time)
```
The analysis can identify sales patterns based on:
- Day of the week
- Hour of the day
- Sales
- Orders
- Quantity sold
This output can also be used to create a day/hour heat map.

## 📊 Dashboard / Visualization Requirements
The SQL analysis was designed to support the following visualization requirements.
1. Calendar Heat Map
- Daily sales visualization
- Selected-month analysis
- Sales intensity by day
- Tooltip metrics:
  - Sales
  - Orders
  - Quantity

2. Weekday vs Weekend Analysis
- Weekday sales
- Weekend sales
- Performance comparison

3. Store Location Analysis
- Sales by store location
- MoM sales comparison
- Increase/decrease identification

4. Daily Sales Analysis
- Daily sales trend
- Average sales line
- Above-average days
- Below-average days

5. Product Category Analysis
- Sales by product category
- Category contribution to total sales

6. Top 10 Products
- Top 10 products by sales
- Product-level performance comparison

7. Day & Hour Analysis
- Sales by day
- Sales by hour
- Orders by day/hour
- Quantity by day/hour
- Heat-map-ready output

## 🛠️ SQL Concepts Used
This project helped apply the following SQL concepts:
Data Definition & Structure
- ALTER TABLE
- MODIFY COLUMN
- CHANGE COLUMN
- DESCRIBE

Data Manipulation
- UPDATE

Data Retrieval
- SELECT
- WHERE
- GROUP BY
- ORDER BY
- LIMIT

Aggregate Functions
- SUM()
- COUNT()
- AVG()
- ROUND()

Date & Time Functions
- DATE_FORMAT()
- STR_TO_DATE()
- MONTH()
- DAY()
- DAYOFWEEK()
- HOUR()

Conditional Logic
- CASE
- WHEN
- THEN
- ELSE

String Functions
- CONCAT()
- INSTR()

Window Functions
- LAG()
- Window calculations using OVER()

Subqueries
Used for calculating average daily sales and comparing individual days against the average.
Data Quality
- NULL checking
- Invalid date detection
- Date standardization
- Data-type conversion
- Column-name cleanup

## 🔄 Project Workflow
                 RAW COFFEE SALES DATA
                          │
                          ▼
                 DATA QUALITY CHECK
                          │
                          ▼
              DATE & TIME STANDARDIZATION
                          │
                          ▼
                   NULL CHECKING
                          │
                          ▼
                 DATA TRANSFORMATION
                          │
                          ▼
                KPI CALCULATIONS
                          │
           ┌──────────────┼──────────────┐
           ▼              ▼              ▼
       SALES           ORDERS        QUANTITY
           │              │              │
           └──────────────┼──────────────┘
                          ▼
                    MoM ANALYSIS
                          │
                          ▼
               PRODUCT / STORE ANALYSIS
                          │
                          ▼
                 TIME-BASED ANALYSIS
                          │
                          ▼
               DASHBOARD-READY OUTPUT

## 💡 Key Learning Outcomes
Through this project, I strengthened my ability to:
- Clean and validate real-world datasets using SQL
- Work with date and time data
- Perform KPI calculations
- Calculate Month-over-Month performance
- Use SQL window functions
- Analyze business performance by different dimensions
- Use subqueries for analytical calculations
- Perform product and store-level analysis
- Analyze sales patterns by day and hour
- Prepare SQL outputs for dashboards and visualizations

## 📂 Project Structure
Coffee-Shop-Sales-SQL/
│
├── README.md
│
├── coffee project.sql
│
└── dataset/
    └── coffee_shop_sales.csv

## 🚀 How to Run the Project
Step 1 — Create / Select Database
Open MySQL Workbench and connect to your MySQL server.
Step 2 — Load the Coffee Sales Dataset
Import the coffee sales dataset into MySQL.
Step 3 — Create the coffee Table
Load the dataset into the table named: coffee
Step 4 — Run Data Cleaning Queries
Execute the data validation and cleaning queries first.
Step 5 — Run KPI Queries
Execute the sales, orders, and quantity analysis queries.
Step 6 — Run Business Analysis
Execute the queries for:
- Store location
- Product category
- Top 10 products
- Weekdays/weekends
- Daily sales
- Hours
- Day/hour analysis
Step 7 — Use the Results for Visualization
The resulting datasets can be connected to a dashboard/visualization tool for further reporting.

## 📌 Project Highlights
Database: MySQL
Language: SQL
Dataset: Coffee Shop Sales
Focus: Data Cleaning + Business Analysis + KPI Reporting
Core Analytical Areas
Sales · Orders · Quantity · MoM Analysis · Store Performance · Product Performance · Time Analysis · Weekday vs Weekend · Top 10 Products

## 👨‍💻 Author
Banoth Mahendar
Data Analyst | SQL | Excel | Power BI | Python
📍 Hyderabad, Telangana
🔗 GitHub: github.com/mahendar432

---

## ⭐ If you find this project useful

Feel free to explore the SQL queries and use the project as a reference for learning SQL-based data analysis
