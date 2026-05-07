USE ROLE EG_ENV_SALES_ENGR_FR;
USE WAREHOUSE EG_ENV_SALES_ENGR_WH;

CREATE OR REPLACE SEQUENCE EG_ENV_SALES_PREP_DB.BASE_MODEL.seq_customer_key START = 1;
CREATE OR REPLACE SEQUENCE EG_ENV_SALES_PREP_DB.BASE_MODEL.seq_product_key START = 1;
CREATE OR REPLACE SEQUENCE EG_ENV_SALES_PREP_DB.BASE_MODEL.seq_customer_master_key START = 1;
CREATE OR REPLACE SEQUENCE EG_ENV_SALES_PREP_DB.BASE_MODEL.seq_opportunity_key START = 1;
CREATE OR REPLACE SEQUENCE EG_ENV_SALES_PREP_DB.BASE_MODEL.seq_order_key START = 1;


-- DIM_CUSTOMERS
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customers (
    customer_key NUMBER PRIMARY KEY,
    customer_id STRING,
    customer_name STRING,
    region STRING,
    industry STRING,
    segment STRING,
    created_date DATE
);

-- DIM_CUSTOMER_MASTER
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customer_master (
    customer_master_key NUMBER PRIMARY KEY,
    customer_id STRING,
    master_customer_name STRING,
    parent_company STRING,
    region_standardized STRING
);

-- DIM_PRODUCTS
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_products (
    product_key NUMBER PRIMARY KEY,
    product_id STRING,
    product_name STRING,
    category STRING,
    price NUMBER(10,2)
);

-- DIM_DATE
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_date (
    date_key INT PRIMARY KEY,       -- YYYYMMDD as integer surrogate key
    full_date DATE,
    day INT,
    month INT,
    year INT,
    quarter INT,
    day_of_week INT,
    month_name STRING,
    is_weekend BOOLEAN,
    fiscal_year INT,
    fiscal_quarter INT
);

-- FACT_OPPORTUNITIES
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_opportunities (
    opportunity_key NUMBER PRIMARY KEY,
    opportunity_id STRING,
    customer_key NUMBER,
    stage STRING,
    amount NUMBER(12,2),
    created_date_key INT,
    close_date_key INT
);

-- FACT_ORDERS
CREATE OR REPLACE TABLE EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_orders (
    order_key NUMBER PRIMARY KEY,
    order_id STRING,
    customer_key NUMBER,
    product_key NUMBER,
    order_date_key INT,
    revenue NUMBER(12,2)
);




