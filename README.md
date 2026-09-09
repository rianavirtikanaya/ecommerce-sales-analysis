# E-Commerce Sales Analysis

## Project Overview

This project analyzes e-commerce transaction data to evaluate sales performance across products, customer segments, cities, payment methods, and time periods.

The project covers the end-to-end analytical process, including data quality assessment, data cleaning and validation, relational data modeling in MySQL, exploratory business analysis, and interactive dashboard development in Power BI.

## Business Problem

The e-commerce dataset lacked a consolidated view of sales performance across products, customer segments, cities, payment methods, and time periods.

The analysis aims to transform raw transactional data into reliable business insights by identifying key sales patterns, top-performing products and categories, customer contributions, geographic performance, payment behavior, and sales trends.

## Dataset

The analysis uses four related e-commerce datasets:

| Table | Records | Description |
|---|---:|---|
| Customers | 10,000 | Customer demographic, location, signup date, and segment information |
| Orders | 50,120 raw records | Transaction details including product, quantity, discount, payment method, and order status |
| Payments | 50,000 | Payment date and payment status for each order |
| Products | 20 | Product name, category, and unit price |

After data quality assessment and duplicate removal, the Orders table contained 50,000 cleaned records used for analysis.

**Source:** [Kaggle — E-Commerce Sales Data Analysis & EDA](https://www.kaggle.com/datasets/erfan4524/e-commerce-sales-data-analysis-and-eda)

## Data Quality Assessment

Before analysis, the raw datasets were assessed for completeness, duplication, key integrity, referential integrity, and data consistency.

Key issues identified included:
- 120 duplicate order records.
- 30 orders with unmatched CustomerID references.
- Missing values in Age, City, OrderDate, Quantity, Discount, PaymentMethod, and PaymentDate.
- Inconsistent city naming (`Mashad` vs `Mashhad`).
- 25 records with non-positive Quantity values.
- Data type inconsistencies in customer fields such as Age and SignupDate.

## Data Cleaning & Preparation

Based on the data quality assessment, the dataset was cleaned and prepared for analysis through the following steps:
- Removed exact duplicate order records, reducing the Orders table from 50,120 to 50,000 records.
- Flagged unmatched CustomerID references to preserve the records while distinguishing them from valid customer relationships.
- Standardized inconsistent city names (`Mashad` to `Mashhad`).
- Converted blank Age and City values to NULL for consistent missing-value handling.
- Standardized Age and SignupDate data types.
- Classified Quantity values as `VALID`, `MISSING`, or `INVALID` to prevent invalid quantities from affecting sales calculations.
- Performed post-cleaning validation to verify duplicate removal, key integrity, standardized values, and remaining missing data.

## Data Model

A relational data model was established in MySQL after data cleaning and validation.
- `CustomerID` was defined as the primary key in the Customers table.
- `ProductID` was defined as the primary key in the Products table.
- `OrderID` was defined as the primary key in the cleaned Orders table.
- `PaymentID` was defined as the primary key in the Payments table.
- Orders were linked to Products through `ProductID`.
- Payments were linked to Orders through `OrderID`.
- Customer relationships were validated separately because 30 order records contained unmatched CustomerID references.

## Analysis

The cleaned dataset was analyzed in MySQL to evaluate overall sales performance and identify key business patterns.

The analysis covered:
- **Sales Overview** — Total orders, units sold, gross sales, discount value, and net sales.
- **Product Performance** — Top products by net sales and units sold, as well as performance by product category.
- **Customer Analysis** — Net sales contribution by customer segment and top customers.
- **Geographic Analysis** — Cities generating the highest net sales.
- **Payment Analysis** — Order distribution by payment method and payment status.
- **Sales Trends** — Monthly and annual net sales trends.

Detailed SQL queries are available in [`sql/analysis.sql`](sql/analysis.sql).

## Dashboard

An interactive Power BI dashboard was developed to consolidate the analysis into a single view of sales performance.

The dashboard includes:
- Key sales KPIs including total orders, units sold, gross sales, net sales, and total discount.
- Sales trends over time.
- Product and product category performance.
- Customer segment and geographic performance.
- Payment method and payment status analysis.
- Interactive filters for exploring different segments of the data.

## Key Insights

- The cleaned dataset contained **50,000 orders** and **93,962 valid units sold**, generating **3,481,553.85 in net sales**.
- **Electronics** was the highest-performing product category, generating **1,769,901.80 in net sales**.
- **Headphones** generated the highest product-level net sales at **336,262.50**, while **Notebook** recorded the highest sales volume with **10,443 units sold**.
- The **Regular** customer segment contributed the highest total net sales at **1,937,694.15**.
- **Tehran** was the leading city by net sales, generating **960,792.00**.
- **Gateway** was the most frequently used payment method with **23,822 orders**, while **46,569 payments (93.14%)** had a Paid status.
- Annual net sales remained relatively stable between **2024 and 2025**. The 2026 data covers only January–June and therefore should not be interpreted as a full-year decline.

## Tools & Technologies

- **MySQL** — Data quality assessment, data cleaning, validation, relational modeling, and business analysis.
- **Power BI** — Data modeling, DAX measures, interactive dashboard development, and visualization.
- **Power Query** — Data transformation and preparation for dashboard development.
