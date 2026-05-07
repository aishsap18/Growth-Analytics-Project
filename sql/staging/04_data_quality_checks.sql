USE ROLE EG_ENV_SALES_ENGR_FR;
USE WAREHOUSE EG_ENV_SALES_ENGR_WH;

-- Customers
SELECT * FROM EG_ENV_SALES_PREP_DB.INGRESS.customers_stg LIMIT 10;

-- Count rows
SELECT COUNT(*) AS total_customers FROM EG_ENV_SALES_PREP_DB.INGRESS.customers_stg; -- 520

--  duplicates & missing keys
SELECT customer_id, COUNT(*) 
FROM EG_ENV_SALES_PREP_DB.INGRESS.customers_stg
GROUP BY customer_id
HAVING COUNT(*) > 1; -- 20 

SELECT * 
FROM EG_ENV_SALES_PREP_DB.INGRESS.customers_stg
WHERE customer_id IS NULL OR TRIM(customer_id) = ''; -- 0

-- Customer Master: 
SELECT * FROM EG_ENV_SALES_PREP_DB.INGRESS.customer_master_stg LIMIT 10;

-- Count rows
SELECT COUNT(*) AS total_customers FROM EG_ENV_SALES_PREP_DB.INGRESS.customer_master_stg; -- 500 
-- duplicates & orphan records
SELECT customer_id, COUNT(*) 
FROM EG_ENV_SALES_PREP_DB.INGRESS.customer_master_stg
GROUP BY customer_id
HAVING COUNT(*) > 1; -- 0

SELECT cm.*
FROM EG_ENV_SALES_PREP_DB.INGRESS.customer_master_stg cm
LEFT JOIN EG_ENV_SALES_PREP_DB.INGRESS.customers_stg c
ON cm.customer_id = c.customer_id
WHERE c.customer_id IS NULL; -- 0

-- Products: 
SELECT * FROM EG_ENV_SALES_PREP_DB.INGRESS.products_stg LIMIT 10;

-- Count rows
SELECT COUNT(*) AS total_customers FROM EG_ENV_SALES_PREP_DB.INGRESS.products_stg; -- 50
-- duplicates & invalid price
SELECT product_id, COUNT(*) 
FROM EG_ENV_SALES_PREP_DB.INGRESS.products_stg
GROUP BY product_id
HAVING COUNT(*) > 1; -- 0

SELECT *
FROM EG_ENV_SALES_PREP_DB.INGRESS.products_stg
WHERE TRY_TO_NUMBER(price) IS NULL; -- 0

-- Opportunities: 
SELECT * FROM EG_ENV_SALES_PREP_DB.INGRESS.opportunities_stg LIMIT 10;

-- Count rows
SELECT COUNT(*) AS total_customers FROM EG_ENV_SALES_PREP_DB.INGRESS.opportunities_stg; -- 1000

-- missing keys & invalid amounts
SELECT *
FROM EG_ENV_SALES_PREP_DB.INGRESS.opportunities_stg
WHERE customer_id IS NULL; -- 0

SELECT *
FROM EG_ENV_SALES_PREP_DB.INGRESS.opportunities_stg
WHERE TRY_TO_NUMBER(amount) IS NULL; -- 197 but all Lost stage

-- Orders: 
SELECT * FROM EG_ENV_SALES_PREP_DB.INGRESS.orders_stg LIMIT 10;

-- Count rows
SELECT COUNT(*) AS total_customers FROM EG_ENV_SALES_PREP_DB.INGRESS.orders_stg; -- 1500

-- missing keys, invalid numbers, orphan records
SELECT *
FROM EG_ENV_SALES_PREP_DB.INGRESS.orders_stg
WHERE customer_id IS NULL OR product_id IS NULL; -- 0

SELECT *
FROM EG_ENV_SALES_PREP_DB.INGRESS.orders_stg
WHERE TRY_TO_NUMBER(revenue) IS NULL; -- 0

-- Orphan customer check
SELECT o.*
FROM EG_ENV_SALES_PREP_DB.INGRESS.orders_stg o
LEFT JOIN EG_ENV_SALES_PREP_DB.INGRESS.customers_stg c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL; -- 0 

-- Orphan product check
SELECT o.*
FROM EG_ENV_SALES_PREP_DB.INGRESS.orders_stg o
LEFT JOIN EG_ENV_SALES_PREP_DB.INGRESS.products_stg p
ON o.product_id = p.product_id
WHERE p.product_id IS NULL; -- 0 