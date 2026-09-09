-- E-Commerce Sales Analysis
-- =====================================================
-- 1. DATABASE SETUP & RAW DATA IMPORT
-- =====================================================

-- 1.1 Database Setup
CREATE DATABASE ecommerce_eda;
USE ecommerce_eda;

-- =====================================================
-- 1.2 IMPORT RAW TABLES
-- =====================================================

-- 1.2.1 Import Customers Raw
-- Imported using MySQL Table Data Import Wizard
SELECT COUNT(*) AS total_rows
FROM customers;
SELECT *
FROM customers
LIMIT 5;

-- 1.2.2 Import Orders Raw
CREATE TABLE orders (
	OrderID INT,
    CustomerID INT,
    OrderDate DATE,
    ProductID INT,
    Quantity INT,
    Discount DOUBLE,
    PaymentMethod VARCHAR(50),
    Status VARCHAR(50)
    );
    
LOAD DATA LOCAL INFILE
'path/to/orders.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(OrderID, CustomerID, @OrderDate, ProductID, @Quantity, @Discount, @PaymentMethod, Status)
SET
    OrderDate = NULLIF(TRIM(@OrderDate), ''),
    Quantity = NULLIF(TRIM(@Quantity), ''),
    Discount = NULLIF(TRIM(@Discount), ''),
    PaymentMethod = NULLIF(TRIM(@PaymentMethod), '');
SELECT COUNT(*) AS total_rows
FROM orders;

-- 1.2.3 Import Payments Raw
CREATE TABLE payments(
	PaymentID INT,
    OrderID INT,
    PaymentDate DATE,
    PaymentStatus VARCHAR(20)
);

LOAD DATA LOCAL INFILE
'path/to/payments.csv'
INTO TABLE payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS (
	PaymentID, OrderID, @PaymentDate, PaymentStatus)
    SET
    PaymentDate = NULLIF(TRIM(@PaymentDate), ''
);
SELECT COUNT(*) total_rows
FROM payments;

-- 1.2.3 Import Products Raw
-- Imported using MySQL Table Data Import Wizard
DESCRIBE products;
SELECT COUNT(*) total_rows
FROM products;

-- =====================================================
-- 1.3 Import Validation.
-- =====================================================
SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'payments', COUNT(*)
FROM payments

UNION ALL

SELECT 'products', COUNT(*)
FROM products;

-- =====================================================
-- 2. DATA QUALITY ASSESSMENT
-- =====================================================

-- 2.1 Missing Value Assessment
-- Customers Table
SELECT 'CustomerID' AS column_name,
       SUM(CustomerID IS NULL) AS missing_values
FROM customers
UNION ALL
SELECT 'Age',
       SUM(Age IS NULL OR TRIM(Age) = '')
FROM customers
UNION ALL
SELECT 'City',
       SUM(City IS NULL OR TRIM(City) = '')
FROM customers
UNION ALL
SELECT 'SignupDate',
       SUM(SignupDate IS NULL OR TRIM(SignupDate) = '')
FROM customers
UNION ALL
SELECT 'CustomerSegment',
       SUM(CustomerSegment IS NULL OR TRIM(CustomerSegment) = '')
FROM customers;

-- Orders table
SELECT 'OrderID' column_name,
	SUM(OrderID IS NULL) missing_values
FROM orders
UNION ALL
SELECT 'CustomerID',
	SUM(CustomerID IS NULL)
FROM orders
UNION ALL
SELECT 'OrderDate',
	SUM(OrderDate IS NULL OR TRIM(OrderDate) = '')
FROM orders
UNION ALL
SELECT 'ProductID',
	SUM(ProductID IS NULL)
FROM orders
UNION ALL
SELECT 'Quantity',
	SUM(Quantity IS NULL)
FROM orders
UNION ALL
SELECT 'Discount',
	SUM(Discount IS NULL OR TRIM(Discount) = '')
FROM orders
UNION ALL
SELECT 'PaymentMethod',
	SUM(PaymentMethod IS NULL OR TRIM(PaymentMethod) = '')
FROM orders
UNION ALL
SELECT 'Status',
	SUM(Status IS NULL OR TRIM(Status) = '')
FROM orders;

-- Payments table
SELECT 'PaymentID' column_name,
	SUM(PaymentID IS NULL) missing_values
FROM payments
UNION ALL
SELECT 'OrderID',
	SUM(OrderID IS NULL)
FROM payments
UNION ALL
SELECT 'PaymentDate',
	SUM(PaymentDate IS NULL OR TRIM(PaymentDate) = '')
FROM payments
UNION ALL
SELECT 'PaymentStatus',
	SUM(PaymentStatus IS NULL OR TRIM(PaymentStatus) = '')
FROM payments;

-- Products Table
SELECT 'ProductID' column_name,
	SUM(ProductID IS NULL) missing_values
FROM products
UNION ALL
SELECT 'ProductName',
	SUM(ProductName IS NULL OR TRIM(ProductName) = '')
FROM products
UNION ALL
SELECT 'Category',
	SUM(Category IS NULL OR TRIM(Category) = '')
FROM products
UNION ALL
SELECT 'UnitPrice',
	SUM(UnitPrice IS NULL)
FROM products;

-- =====================================================
-- 2.2 DUPLICATE VALIDATION
-- =====================================================

-- Customers Table
SELECT 
    CustomerID,
    Age,
    City,
    SignupDate,
    CustomerSegment,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY 
    CustomerID,
    Age,
    City,
    SignupDate,
    CustomerSegment
HAVING COUNT(*) > 1;

-- Orders Table
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    ProductID,
    Quantity,
    Discount,
    PaymentMethod,
    Status,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY
    OrderID,
    CustomerID,
    OrderDate,
    ProductID,
    Quantity,
    Discount,
    PaymentMethod,
    Status
HAVING COUNT(*) > 1;

-- Payments Table
SELECT
	PaymentID,
    OrderID,
    PaymentDate,
    PaymentStatus,
    COUNT(*) duplicate_count
    FROM payments
GROUP BY
	PaymentID,
    OrderID,
    PaymentDate,
    PaymentStatus
HAVING COUNT(*) > 1;

-- Product Table
SELECT 
	ProductID,
    ProductName,
    Category,
    UnitPrice,
    COUNT(*) duplicate_count
FROM products
GROUP BY 
	ProductID,
    ProductName,
    Category,
    UnitPrice
HAVING COUNT(*) > 1;

-- =====================================================
-- 2.3 PRIMARY KEY VALIDATION
-- =====================================================

-- Customer Table (CustomerID)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CustomerID) AS unique_customer_id,
    SUM(CustomerID IS NULL) AS null_customer_id
FROM customers;

-- Orders Table (OrderID)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT OrderID) AS unique_OrderID,
    SUM(OrderID IS NULL) AS null_OrderID
FROM orders;

-- Payments Table (PaymentID)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT PaymentID) AS unique_PaymentID,
    SUM(PaymentID IS NULL) AS null_PaymentID
FROM payments;

-- Product Table (ProductID)
SELECT
	COUNT(*) total_rows,
    COUNT(DISTINCT ProductID) unique_ProductID,
    SUM(ProductID IS NULL) null_ProductID
FROM products;

-- =====================================================
-- 2.4 Referential Integrity Validation.
-- =====================================================
SELECT COUNT(*) orphan_customer_records
FROM orders o
LEFT JOIN customers c
	ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

SELECT COUNT(*) orphan_product_record
FROM orders o
LEFT JOIN products p
	ON o.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

SELECT COUNT(*) orphan_payment_records
FROM payments p
LEFT JOIN orders o
    ON p.OrderID = o.OrderID
WHERE o.OrderID IS NULL;

-- =====================================================
-- 2.5 DATA CONSISTENCY VALIDATION
-- =====================================================

-- Customers Table
SELECT CustomerSegment,
	COUNT(*) total_customers
FROM customers
GROUP BY CustomerSegment
ORDER BY total_customers DESC;

SELECT City,
	COUNT(*) total_customers
FROM customers
GROUP BY City
ORDER BY total_customers DESC;

SELECT
    MIN(
        CASE
            WHEN Age IS NOT NULL AND TRIM(Age) <> ''
            THEN CAST(Age AS UNSIGNED)
        END
    ) AS min_age,
    MAX(
        CASE
            WHEN Age IS NOT NULL AND TRIM(Age) <> ''
            THEN CAST(Age AS UNSIGNED)
        END
    ) AS max_age,

    SUM(Age IS NULL OR TRIM(Age) = '') AS missing_age
FROM customers;

SELECT
    MIN(CAST(SignupDate AS DATE)) earliest_signup,
    MAX(CAST(SignupDate AS DATE)) latest_signup,
    SUM(SignupDate IS NULL OR TRIM(SignupDate) = '') AS missing_signup
FROM customers;

-- Orders Table
SELECT 'PaymentMethod' column_name,
	PaymentMethod value,
	COUNT(*) total_records
FROM orders
GROUP BY PaymentMethod
UNION ALL
SELECT 'Status',
	Status,
    COUNT(*)
FROM orders
GROUP BY Status
ORDER BY column_name, total_records DESC;

SELECT
    MIN(Quantity) min_quantity,
    MAX(Quantity) max_quantity,
    SUM(Quantity IS NULL) missing_quantity, 
    MIN(Discount) min_discount,
    MAX(Discount) max_discount,
    SUM(Discount IS NULL) missing_discount
FROM orders;

SELECT
    Quantity, Status,
    COUNT(*) AS total_records
FROM orders
WHERE Quantity <= 0
GROUP BY Quantity, Status
ORDER BY Status, Quantity;

SELECT
    MIN(OrderDate) earliest_order,
    MAX(OrderDate) latest_order,
    SUM(OrderDate IS NULL) missing_dateorder
FROM orders;

-- Payments Table
SELECT PaymentStatus,
	COUNT(*) total_paymentstatus
FROM payments
GROUP BY PaymentStatus
ORDER BY total_paymentstatus DESC;

SELECT
    MIN(PaymentDate) earliest_payment,
    MAX(PaymentDate) latest_payment,
    SUM(PaymentDate IS NULL) missing_paymentdate
FROM payments;

SELECT Category,
	COUNT(*) total_category
FROM products
GROUP BY Category
ORDER BY total_category DESC;

SELECT
    MIN(UnitPrice) min_UnitPrice,
    MAX(UnitPrice) max_UnitPrice,
    SUM(UnitPrice IS NULL) missing_UnitPrice
FROM products;

-- =====================================================
-- 3. DATA CLEANING
-- =====================================================

-- 3.1 Handle Missing Values
-- Investigate missing OrderDate and PaymentDate
SELECT 
	o.OrderID,
	o.OrderDate,
    p.PaymentDate
FROM orders o
LEFT JOIN payments p
	ON o.OrderID = p.OrderID
WHERE o.OrderDate IS NULL OR p.PaymentDate IS NULL;

-- Investigate missing Quantity
SELECT Status,
	COUNT(*) total_records
FROM orders
WHERE Quantity IS NULL
GROUP BY Status
ORDER BY total_records DESC;

SELECT ProductID,
	COUNT(*) total_missingquantity
FROM orders
WHERE Quantity IS NULL
GROUP BY ProductID
ORDER BY total_missingquantity DESC;

-- Investigate missing Discount
SELECT Discount,
	COUNT(*) total_records
FROM orders
GROUP BY Discount
ORDER BY Discount DESC;

-- Investigate missing PaymentMethod
SELECT 
    p.PaymentStatus,
    COUNT(*) AS total_records
FROM orders o 
LEFT JOIN payments p 
    ON o.OrderID = p.OrderID
WHERE o.PaymentMethod IS NULL
GROUP BY p.PaymentStatus
ORDER BY total_records DESC;

-- Investigate records with missing transaction dates
SELECT Status,
	COUNT(*) total_records
FROM orders
WHERE OrderDate IS NULL
GROUP BY Status
ORDER BY total_records DESC;

-- Check completeness of records with missing transaction dates
SELECT 
	COUNT(*) total_records,
    SUM(Quantity IS NULL) missing_quantity,
    SUM(Discount IS NULL) missing_discount,
	SUM(PaymentMethod IS NULL) missing_payment_method
FROM orders
WHERE OrderDate IS NULL;

-- Assess impact of missing Quantity
SELECT
	COUNT(*) total_orders,
    SUM(Quantity IS NULL) missing_quantity,
    ROUND(SUM(Quantity IS NULL) / COUNT(*) * 100,
        2) missing_percentage
FROM orders;

-- Assess impact of missing Discount
SELECT
	COUNT(*) total_orders,
    SUM(Discount IS NULL) missing_discount,
    ROUND(SUM(Discount IS NULL) / COUNT(*) * 100,
        2) missing_percentage
FROM orders;

-- Assess impact of missing PaymentMethod
SELECT
	COUNT(*) total_orders,
    SUM(PaymentMethod IS NULL) missing_payment_method,
    ROUND(SUM(PaymentMethod IS NULL) / COUNT(*) * 100,
        2) missing_percentage
FROM orders;

-- Assess impact of missing Age
SELECT
	COUNT(*) total_customers,
    SUM(Age IS NULL OR TRIM(Age) = '') missing_age,
    ROUND(SUM(Age IS NULL OR TRIM(Age) = '') / COUNT(*) * 100,
        2) missing_percentage
FROM customers;

-- Assess impact of missing City
SELECT
	COUNT(*) total_customers,
    SUM(City IS NULL OR TRIM(City) = '') missing_city,
    ROUND(SUM(City IS NULL OR TRIM(City) = '') / COUNT(*) * 100,
        2) missing_percentage
FROM customers;

-- =====================================================
-- 3.2 Remove Duplicate Records
-- =====================================================

-- Remove exact duplicate orders

-- Create deduplicated orders table
CREATE TABLE orders_clean
SELECT DISTINCT *
FROM orders;

-- Validate duplicate removal
SELECT 
	(SELECT COUNT(*) FROM orders) raw_orders,
    (SELECT COUNT(*) FROM orders_clean) clean_orders,
    (SELECT COUNT(*) FROM orders) - 
    (SELECT COUNT(*) FROM orders_clean) removed_duplicates;
    
SELECT OrderID, CustomerID, OrderDate, ProductID, Quantity, Discount, PaymentMethod, Status,
    COUNT(*) AS duplicate_count
FROM orders_clean
GROUP BY OrderID, CustomerID, OrderDate, ProductID, Quantity, Discount, PaymentMethod, Status
HAVING COUNT(*) > 1;

-- =====================================================
-- 3.3 Handle Invalid References
-- =====================================================

-- Investigate orders with invalid CustomerID references
SELECT COUNT(*) orphan_customer_records
FROM orders_clean o
LEFT JOIN customers c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

-- Identify invalid CustomerID values
SELECT o.CustomerID,
	COUNT(*) total_orders
FROM orders_clean o
LEFT JOIN customers c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL
GROUP BY o.CustomerID
ORDER BY total_orders DESC;

-- Investigate orders associated with invalid CustomerID
SELECT Status,
	COUNT(*) total_orders
FROM orders_clean
WHERE CustomerID = '999999'
GROUP BY Status;

-- Update customer reference status
ALTER TABLE orders_clean
ADD COLUMN customer_reference_status VARCHAR(20)
NOT NULL DEFAULT 'VALID';
DESCRIBE orders_clean;

SET SQL_SAFE_UPDATES = 0;
UPDATE orders_clean
SET customer_reference_status = 'UNMATCHED'
WHERE CustomerID = 999999;
SET SQL_SAFE_UPDATES = 1;

SELECT
    customer_reference_status,
    COUNT(*) AS total_records
FROM orders_clean
GROUP BY customer_reference_status;

-- =====================================================
-- 3.4 Standardize Data
-- =====================================================

-- Standardize City values
SET SQL_SAFE_UPDATES = 0;
UPDATE customers
SET City = 'Mashhad' WHERE City = 'Mashad';
SET SQL_SAFE_UPDATES = 1;

SELECT City,
	COUNT(*) total_customers
FROM customers
WHERE City IN ('Mashad', 'Mashhad')
GROUP BY City;

-- Standardize blank Age values to NULL
SET SQL_SAFE_UPDATES = 0;
UPDATE customers
SET Age = NULL WHERE TRIM(Age) = '';
SET SQL_SAFE_UPDATES = 1;

SELECT
    SUM(Age IS NULL) AS null_age,
    SUM(TRIM(Age) = '') AS blank_age
FROM customers;

-- Standardize blank City values to NULL
SET SQL_SAFE_UPDATES = 0;
UPDATE customers
SET City = NULL WHERE TRIM(City) = '';
SET SQL_SAFE_UPDATES = 1;

SELECT 
	SUM(City IS NULL) null_city,
    SUM(TRIM(City) = '') blank_city
FROM customers;

-- Standardize Age data type
ALTER TABLE customers
MODIFY COLUMN Age INT;

-- Standardize SignupDate data type
ALTER TABLE customers
MODIFY COLUMN SignupDate DATE;

-- Review text column lengths
SELECT 
    (SELECT MAX(CHAR_LENGTH(City)) FROM customers) AS max_city_length,
    (SELECT MAX(CHAR_LENGTH(CustomerSegment)) FROM customers) AS max_CS_length,
	(SELECT MAX(CHAR_LENGTH(ProductName)) FROM products) AS max_PN_length,
	(SELECT MAX(CHAR_LENGTH(Category)) FROM products) AS max_category_length;

-- Standardize text column data types
ALTER TABLE customers
MODIFY COLUMN City VARCHAR(50),
MODIFY COLUMN CustomerSegment VARCHAR(20);

ALTER TABLE products
MODIFY COLUMN ProductName VARCHAR(100),
MODIFY COLUMN Category VARCHAR(50);

-- Handle invalid Quantity values
ALTER TABLE orders_clean
ADD COLUMN quantity_status VARCHAR(20);

-- Classify Quantity values
SET SQL_SAFE_UPDATES = 0;
UPDATE orders_clean
SET quantity_status =
	CASE
		WHEN Quantity IS NULL THEN 'MISSING'
        WHEN Quantity <= 0 THEN 'INVALID'
        ELSE 'VALID'
	END;
SET SQL_SAFE_UPDATES = 1;

SELECT quantity_status,
	COUNT(*) total_records
FROM orders_clean
GROUP BY quantity_status;

-- =====================================================
-- 3.5 Post-Cleaning Validation
-- =====================================================
SELECT COUNT(*) final_orders
FROM orders_clean;
SELECT OrderID, CustomerID, OrderDate, ProductID, Quantity, Discount, PaymentMethod, Status,
    COUNT(*) AS duplicate_count
FROM orders_clean
GROUP BY OrderID, CustomerID, OrderDate, ProductID, Quantity, Discount, PaymentMethod, Status
HAVING COUNT(*) > 1;

-- Validate primary key uniqueness
SELECT
	COUNT(*) total_rows,
    COUNT(DISTINCT OrderID) unique_id,
    SUM(OrderID IS NULL) null_id
FROM orders_clean;

-- Validate referential integrity after cleaning
SELECT customer_reference_status,
	COUNT(*) total_records
FROM orders_clean
GROUP BY customer_reference_status;

-- Validate standardized customer data
SELECT 
	SUM(Age IS NULL) null_age,
    SUM(TRIM(Age) = '') blank_age,
	SUM(City IS NULL) null_city,
    SUM(TRIM(City) = '') blank_city,
    SUM(City = 'Mashad') mashad_remaining
FROM customers;

-- Validate remaining missing values
SELECT
	SUM(OrderDate IS NULL) orderdate_null,
    SUM(Quantity IS NULL) quantity_null,
    SUM(Discount IS NULL) discount_null,
    SUM(PaymentMethod IS NULL) PM_null
FROM orders_clean;

-- Compare missing values before and after deduplication
SELECT
    'Raw' AS dataset,
    SUM(Discount IS NULL) AS discount_null,
    SUM(PaymentMethod IS NULL) AS paymentmethod_null
FROM orders

UNION ALL

SELECT
    'Clean' AS dataset,
    SUM(Discount IS NULL) AS discount_null,
    SUM(PaymentMethod IS NULL) AS paymentmethod_null
FROM orders_clean;

-- Validate remaining PaymentDate missing values
SELECT
	SUM(PaymentDate IS NULL) pd_null
FROM payments;

-- =====================================================
-- 4. RELATIONAL DATA MODEL
-- =====================================================

-- 4.1 Customers
ALTER TABLE customers
ADD PRIMARY KEY (CustomerID);

-- 4.2 Products
ALTER TABLE products
ADD PRIMARY KEY (ProductID);

-- 4.3 Orders
ALTER TABLE orders_clean
ADD PRIMARY KEY (OrderID);

-- 4.4 Payments
ALTER TABLE payments
ADD PRIMARY KEY (PaymentID);

-- 4.5 Primary & Foreign Keys
ALTER TABLE orders_clean
ADD CONSTRAINT productid_fk
FOREIGN KEY (ProductID)
REFERENCES products(ProductID);

-- Add Order foreign key to Payments
ALTER TABLE payments
ADD CONSTRAINT orderid_fk
FOREIGN KEY (OrderID)
REFERENCES orders_clean(OrderID);

-- Validate foreign key constraints
SHOW CREATE TABLE orders_clean;
SHOW CREATE TABLE payments;

-- Validate unresolved Customer foreign key relationship
SELECT COUNT(*) AS unmatched_customers
FROM orders_clean o
LEFT JOIN customers c
    ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

-- =====================================================
-- 5. E-COMMERCE SALES ANALYSIS
-- =====================================================

-- 5.1 Sales Overview
SELECT 
    'Total Orders' AS metric,
    COUNT(*) AS value
FROM orders_clean

UNION ALL

SELECT 
    'Total Units Sold',
    SUM(Quantity)
FROM orders_clean
WHERE quantity_status = 'VALID'

UNION ALL

SELECT
    'Gross Sales',
    ROUND(SUM(Quantity * UnitPrice), 2)
FROM orders_clean o
LEFT JOIN products p
    ON o.ProductID = p.ProductID
WHERE quantity_status = 'VALID'
  AND Discount IS NOT NULL

UNION ALL

SELECT
    'Total Discount Value',
    ROUND(SUM(Quantity * UnitPrice * Discount), 2)
FROM orders_clean o
LEFT JOIN products p
    ON o.ProductID = p.ProductID
WHERE quantity_status = 'VALID'
  AND Discount IS NOT NULL

UNION ALL

SELECT
    'Net Sales',
    ROUND(SUM(Quantity * UnitPrice * (1 - Discount)), 2)
FROM orders_clean o
LEFT JOIN products p
    ON o.ProductID = p.ProductID
WHERE quantity_status = 'VALID'
  AND Discount IS NOT NULL;
  
-- =====================================================
-- 5.2 Product Performance
-- =====================================================

-- 5.2.1 Top 5 Products by Net Sales
SELECT ProductName,
	ROUND(SUM(Quantity * UnitPrice * (1 - Discount)), 2) net_sales
FROM orders_clean o
LEFT JOIN products p
	ON o.ProductID = p.ProductID
WHERE quantity_status = 'VALID' AND Discount IS NOT NULL
GROUP BY ProductName
ORDER BY net_sales DESC
LIMIT 5;

-- 5.2.2 Net Sales by Product Category
SELECT Category,
	ROUND(SUM(Quantity * UnitPrice * (1 - Discount)), 2) net_sales
FROM orders_clean o
LEFT JOIN products p
	ON o.ProductID = p.ProductID
WHERE quantity_status = 'VALID' AND Discount IS NOT NULL
GROUP BY Category
ORDER BY net_sales DESC;

-- 5.2.3 Top 5 Products by Units Sold
SELECT ProductName,
	SUM(Quantity) total_units_sold
FROM orders_clean o
LEFT JOIN products p
	ON o.ProductID = p.ProductID
WHERE quantity_status = 'VALID' 
GROUP BY ProductName
ORDER BY total_units_sold DESC
LIMIT 5;

-- =====================================================
-- 5.3 Customer Analysis
-- =====================================================

-- 5.3.1 Net Sales by Customer Segment
SELECT CustomerSegment,
	ROUND(SUM(Quantity* UnitPrice*(1-Discount)),2) net_sales
FROM orders_clean o
LEFT JOIN customers c
	ON o.CustomerID = c.CustomerID
LEFT JOIN products p
	ON o.ProductID = p.ProductID
WHERE customer_reference_status = 'VALID'
	AND quantity_status = 'VALID'
	AND Discount IS NOT NULL
GROUP BY CustomerSegment
ORDER BY net_sales DESC;

-- 5.3.2 Top 5 Customers by Net Sales
SELECT o.CustomerID,
	ROUND(SUM(Quantity* UnitPrice*(1-Discount)),2) net_sales
FROM orders_clean o
LEFT JOIN customers c
	ON o.CustomerID = c.CustomerID
LEFT JOIN products p
	ON o.ProductID = p.ProductID
WHERE customer_reference_status = 'VALID'
	AND quantity_status = 'VALID'
	AND Discount IS NOT NULL
GROUP BY o.CustomerID
ORDER BY net_sales DESC
LIMIT 5;

-- =====================================================
-- 5.4 Geographic Analysis
-- =====================================================

-- 5.4.1 Top 5 Cities by Net Sales
SELECT City,
	ROUND(SUM(Quantity* UnitPrice*(1-Discount)),2) net_sales
FROM orders_clean o
LEFT JOIN customers c
	ON o.CustomerID = c.CustomerID
LEFT JOIN products p
	ON o.ProductID = p.ProductID
WHERE customer_reference_status = 'VALID'
	AND quantity_status = 'VALID'
	AND Discount IS NOT NULL
GROUP BY City
ORDER BY net_sales DESC
LIMIT 5;

-- =====================================================
-- 5.5 Payment Analysis
-- =====================================================

-- 5.5.1 Orders by Payment Method
SELECT PaymentMethod,
       COUNT(*) AS total_orders
FROM orders_clean
GROUP BY PaymentMethod
ORDER BY total_orders DESC;

-- 5.5.2 Orders by Payment Status
SELECT PaymentStatus,
	COUNT(*) total_orders
FROM payments
GROUP BY PaymentStatus
ORDER BY total_orders DESC;

-- =====================================================
-- 5.6 Sales Trends
-- =====================================================

-- 5.6.1 Monthly Net Sales Trend
SELECT 
    DATE_FORMAT(OrderDate, '%Y-%m') AS month,
    ROUND(SUM(Quantity * UnitPrice * (1 - Discount)), 2) AS net_sales
FROM orders_clean o
LEFT JOIN products p
    ON o.ProductID = p.ProductID
WHERE OrderDate IS NOT NULL
  AND quantity_status = 'VALID'
  AND Discount IS NOT NULL
GROUP BY month
ORDER BY month ASC;

-- 5.6.2 Annual Net Sales Trend
SELECT 
    YEAR(OrderDate) AS year,
    ROUND(SUM(Quantity * UnitPrice * (1 - Discount)), 2) AS net_sales
FROM orders_clean o
LEFT JOIN products p
    ON o.ProductID = p.ProductID
WHERE OrderDate IS NOT NULL
  AND quantity_status = 'VALID'
  AND Discount IS NOT NULL
GROUP BY year
ORDER BY year ASC;

-- =====================================================
-- 6. FINAL BUSINESS INSIGHTS
-- =====================================================

-- 6.1 Overall Sales Performance
-- The cleaned dataset contains 50,000 orders and 93,962 valid units sold.
-- Gross sales reached 3,768,277.00, with a total discount value of
-- 286,723.15, resulting in net sales of 3,481,553.85.

-- 6.2 Product Performance
-- Headphones generated the highest net sales at 336,262.50, followed
-- closely by Office Chair at 332,640.00.
-- In terms of sales volume, Notebook ranked first with 10,443 units sold,
-- indicating that the highest-volume products were not necessarily
-- the highest revenue-generating products.

-- 6.3 Product Category Performance
-- Electronics was the leading product category, generating
-- 1,769,901.80 in net sales, the highest among all product categories.

-- 6.4 Customer Performance
-- The Regular customer segment generated the highest total net sales
-- at 1,937,694.15, followed by New and VIP customers.
-- This represents total segment contribution and should not be
-- interpreted as higher spending per individual customer.

-- 6.5 Geographic Performance
-- Tehran was the leading city by net sales at 960,792.00,
-- followed by Mashhad and Karaj.

-- 6.6 Payment Performance
-- Gateway was the most frequently used payment method, accounting for
-- 23,822 of 50,000 orders.
-- Payment records showed 46,569 Paid transactions, representing
-- approximately 93.14% of all payments.

-- 6.7 Sales Trend
-- Annual net sales were relatively stable between 2024
-- (1,474,559.25) and 2025 (1,459,606.55).
-- The 2026 total of 545,540.15 represents only January through June,
-- so it should not be directly interpreted as a full-year decline.
