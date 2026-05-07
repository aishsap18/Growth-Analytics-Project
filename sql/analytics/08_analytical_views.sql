USE ROLE EG_ENV_SALES_ANALYTICS_ENGR_FR;
USE WAREHOUSE EG_ENV_SALES_ANALYTICS_ENGR_WH;


CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_CUSTOMERS_VW AS (
    SELECT 
        customer_key AS "Customer Key",
        customer_id AS "Customer Id",
        customer_name AS "Customer Name",
        region AS "Region",
        industry AS "Industry",
        segment AS "Segment",
        created_date as "Created Date"
    FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.DIM_CUSTOMERS
);

CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.REPORT.DIM_CUSTOMERS_VW AS (
    SELECT * FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_CUSTOMERS_VW
);


CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_CUSTOMER_MASTER_VW AS (
    SELECT 
        customer_master_key AS "Customer Master Key",
        customer_id AS "Customer Id",
        master_customer_name AS "Master Customer Name",
        parent_company AS "Parent Company",
        region_standardized As "Standardized Region"
    FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.DIM_CUSTOMER_MASTER
);

CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.REPORT.DIM_CUSTOMER_MASTER_VW AS (
    SELECT * FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_CUSTOMER_MASTER_VW
);


CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_PRODUCTS_VW AS (
    SELECT 
        product_key AS "Product Key",
        product_id AS "Product Id",
        product_name AS "Product Name",
        category AS "Category",
        price AS "Price"
    FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.DIM_PRODUCTS
);

CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.REPORT.DIM_PRODUCTS_VW AS (
    SELECT * FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_PRODUCTS_VW
);


CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_DATE_VW AS (
    SELECT 
        date_key AS "Date Key",
        full_date AS "Full Date",
        day AS "Day",
        month AS "Month",
        year AS "Year",
        quarter AS "Quarter",
        day_of_week AS "Day of Week",
        month_name AS "Month Name",
        is_weekend AS "Is Weekend",
        fiscal_year AS "Fiscal Year",
        fiscal_quarter AS "Fiscal Quarter"
    FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.DIM_DATE
);

CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.REPORT.DIM_DATE_VW AS (
    SELECT * FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.DIM_DATE_VW
);


CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_OPPORTUNITIES_VW AS (
    SELECT 
        customer_key AS "Customer Key",
        CONCAT(LEFT(created_date_key, 6), '01')  AS "Created Date Key",
        CONCAT(LEFT(close_date_key, 6), '01') AS "Close Date Key",
        stage AS "Stage",
        COUNT(opportunity_id) AS "Total Opportunities",
        SUM(amount) AS "Total Amount",
        AVG(amount) AS "Average Amount"
        
    FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.FACT_OPPORTUNITIES
    GROUP BY
        customer_key,
        stage,
        "Created Date Key",
        "Close Date Key"
);

CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.REPORT.FACT_OPPORTUNITIES_VW AS (
    SELECT * FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_OPPORTUNITIES_VW
);


CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_ORDERS_VW AS (
    SELECT 
        customer_key AS "Customer Key",
        product_key AS "Product Key",
        CONCAT(LEFT(order_date_key, 6), '01')  AS "Order Date Key",
        COUNT(ORDER_ID) AS "Total Orders",        
        SUM(revenue) AS "Total Revenue",
        AVG(revenue) AS "Average Revenue"

    FROM EG_ENV_SALES_PREP_DB.BASE_MODEL.FACT_ORDERS
    GROUP BY
        customer_key,
        product_key,
        "Order Date Key"
);

CREATE OR REPLACE VIEW EG_ENV_SALES_ANALYTICS_DB.REPORT.FACT_ORDERS_VW AS (
    SELECT * FROM EG_ENV_SALES_ANALYTICS_DB.PRE_REPORT.FACT_ORDERS_VW
);
