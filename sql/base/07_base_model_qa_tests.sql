USE ROLE EG_ENV_SALES_ENGR_FR;
USE WAREHOUSE EG_ENV_SALES_ENGR_WH;

-- dim_customers

-- Check for missing surrogate keys
SELECT COUNT(*) AS missing_customer_key
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customers
WHERE customer_key IS NULL;

-- Check for duplicate business keys
SELECT customer_id, COUNT(*) AS cnt
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Check for null critical fields
SELECT COUNT(*) AS missing_critical
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customers
WHERE customer_id IS NULL
   OR customer_name IS NULL
   OR region IS NULL;


-- dim_customer_master

-- Missing surrogate keys
SELECT COUNT(*) AS missing_customer_master_key
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customer_master
WHERE customer_master_key IS NULL;

-- Duplicate customer_id check
SELECT customer_id, COUNT(*) AS cnt
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customer_master
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- dim_products

-- Missing product_key
SELECT COUNT(*) AS missing_product_key
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_products
WHERE product_key IS NULL;

-- Duplicate product_id check
SELECT product_id, COUNT(*) AS cnt
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Price nulls / negative
SELECT COUNT(*) AS invalid_price
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_products
WHERE price IS NULL OR price < 0;


-- fact_opportunities

-- Missing surrogate keys / customer_key
SELECT COUNT(*) AS missing_keys
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_opportunities
WHERE opportunity_key IS NULL
   OR customer_key IS NULL;

-- Duplicate natural keys
SELECT opportunity_id, COUNT(*) AS cnt
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_opportunities
GROUP BY opportunity_id
HAVING COUNT(*) > 1;

-- Amount null / negative
SELECT COUNT(*) AS invalid_amount
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_opportunities
WHERE amount IS NULL OR amount < 0;


-- fact_orders

-- Missing surrogate keys / customer/product keys
SELECT COUNT(*) AS missing_keys
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_orders
WHERE order_key IS NULL
   OR customer_key IS NULL
   OR product_key IS NULL;

-- Duplicate natural keys
SELECT order_id, COUNT(*) AS cnt
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Revenue null / negative
SELECT COUNT(*) AS invalid_revenue
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_orders
WHERE revenue IS NULL OR revenue < 0;

-- Referential integrity check (FK exists)
SELECT COUNT(*) AS missing_customer_or_product
FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_orders f
LEFT JOIN EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customers c ON f.customer_key = c.customer_key
LEFT JOIN EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_products p ON f.product_key = p.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;


