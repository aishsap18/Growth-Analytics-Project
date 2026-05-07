USE ROLE EG_ENV_SALES_ENGR_FR;
USE WAREHOUSE EG_ENV_SALES_ENGR_WH;


-- Customers staging 
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.INGRESS.customers_stg (
    customer_id STRING,
    customer_name STRING,
    region STRING,
    industry STRING,
    segment STRING,
    created_date STRING
);

-- Customer master staging 
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.INGRESS.customer_master_stg (
    customer_id STRING,
    master_customer_name STRING,
    parent_company STRING,
    region_standardized STRING
);

-- Products staging 
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.INGRESS.products_stg (
    product_id STRING,
    product_name STRING,
    category STRING,
    price STRING
);

-- Opportunities staging 
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.INGRESS.opportunities_stg (
    opportunity_id STRING,
    customer_id STRING,
    stage STRING,
    amount STRING,
    created_date STRING,
    close_date STRING
);

-- Orders staging 
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.INGRESS.orders_stg (
    order_id STRING,
    customer_id STRING,
    product_id STRING,
    order_date STRING,
    revenue STRING
);