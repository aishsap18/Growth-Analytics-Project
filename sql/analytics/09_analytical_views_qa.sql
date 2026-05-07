USE ROLE EG_ENV_SALES_ANALYTICS_ENGR_FR;
USE WAREHOUSE EG_ENV_SALES_ANALYTICS_ENGR_WH;

-- =====================================
-- QA Script for Analytical Views
-- Checks: row counts, nulls, duplicates, basic aggregates
-- =====================================

-- 1. Check row counts for each PRE_REPORT view
SELECT 'DIM_CUSTOMERS_VW' AS view_name, COUNT(*) AS row_count
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_CUSTOMERS_VW; 

SELECT 'DIM_CUSTOMER_MASTER_VW' AS view_name, COUNT(*) AS row_count
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_CUSTOMER_MASTER_VW;

SELECT 'DIM_PRODUCTS_VW' AS view_name, COUNT(*) AS row_count
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_PRODUCTS_VW;

SELECT 'DIM_DATE_VW' AS view_name, COUNT(*) AS row_count
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_DATE_VW;

SELECT 'FACT_OPPORTUNITIES_VW' AS view_name, COUNT(*) AS row_count
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_OPPORTUNITIES_VW;

SELECT 'FACT_ORDERS_VW' AS view_name, COUNT(*) AS row_count
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_ORDERS_VW;

-- 2. Check for nulls in surrogate / natural keys
SELECT 'DIM_CUSTOMERS_VW' AS view_name, COUNT(*) AS null_keys
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_CUSTOMERS_VW
WHERE "Customer Key" IS NULL OR "Customer Id" IS NULL;

SELECT 'DIM_PRODUCTS_VW' AS view_name, COUNT(*) AS null_keys
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_PRODUCTS_VW
WHERE "Product Key" IS NULL OR "Product Id" IS NULL;

SELECT 'FACT_OPPORTUNITIES_VW' AS view_name, COUNT(*) AS null_keys
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_OPPORTUNITIES_VW
WHERE "Customer Key" IS NULL OR "Created Date Key" IS NULL;

SELECT 'FACT_ORDERS_VW' AS view_name, COUNT(*) AS null_keys
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_ORDERS_VW
WHERE "Customer Key" IS NULL OR "Product Key" IS NULL OR "Order Date Key" IS NULL;

-- 3. Check for duplicates in dimension surrogate keys
SELECT "Customer Key", COUNT(*) AS dup_count
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_CUSTOMERS_VW
GROUP BY "Customer Key"
HAVING COUNT(*) > 1;

SELECT "Product Key", COUNT(*) AS dup_count
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_PRODUCTS_VW
GROUP BY "Product Key"
HAVING COUNT(*) > 1;

-- 4. Basic sanity checks on aggregated fact measures
SELECT SUM("Total Opportunities") AS total_opps,
       SUM("Total Amount") AS total_pipeline
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_OPPORTUNITIES_VW;

SELECT SUM("Total Orders") AS total_orders,
       SUM("Total Revenue") AS total_revenue
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_ORDERS_VW;

-- 5. Check monthly aggregation consistency
SELECT LEFT("Created Date Key",6) AS yyyymm, COUNT(*) AS opp_count, SUM("Total Opportunities") AS total_opp
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_OPPORTUNITIES_VW
GROUP BY LEFT("Created Date Key",6)
ORDER BY yyyymm;

SELECT LEFT("Order Date Key",6) AS yyyymm, COUNT(*) AS order_count, SUM("Total Orders") AS total_orders
FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_ORDERS_VW
GROUP BY LEFT("Order Date Key",6)
ORDER BY yyyymm;

