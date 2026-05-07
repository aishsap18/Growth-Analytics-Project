USE ROLE EG_ENV_SALES_ENGR_FR;
USE WAREHOUSE EG_ENV_SALES_ENGR_WH;

CREATE OR REPLACE PROCEDURE EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_dim_customers()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

MERGE INTO EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customers tgt
USING (
    SELECT *
    FROM (
        SELECT
            TRIM(customer_id) AS customer_id,
            INITCAP(TRIM(customer_name)) AS customer_name,
            UPPER(TRIM(region)) AS region,
            LOWER(TRIM(industry)) AS industry,
            TRIM(segment) AS segment,
            TRY_TO_DATE(created_date) AS created_date,
            ROW_NUMBER() OVER (
                PARTITION BY TRIM(customer_id)
                ORDER BY TRY_TO_DATE(created_date) DESC
            ) rn
        FROM EG_ENV_SALES_PREP_DB.INGRESS.customers_stg
        WHERE customer_id IS NOT NULL
    )
    WHERE rn = 1
) src
ON tgt.customer_id = src.customer_id

WHEN MATCHED THEN UPDATE SET
    customer_name = src.customer_name,
    region = src.region,
    industry = src.industry,
    segment = src.segment,
    created_date = src.created_date

WHEN NOT MATCHED THEN INSERT (
    customer_key, customer_id, customer_name, region, industry, segment, created_date
)
VALUES (
    seq_customer_key.NEXTVAL,
    src.customer_id, src.customer_name, src.region,
    src.industry, src.segment, src.created_date
);

RETURN 'dim_customers loaded';

END;
$$;



CREATE OR REPLACE PROCEDURE EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_dim_customer_master()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

MERGE INTO EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customer_master tgt
USING (
    SELECT *
    FROM (
        SELECT 
            TRIM(customer_id) AS customer_id,
            INITCAP(TRIM(master_customer_name)) AS master_customer_name,
            INITCAP(TRIM(parent_company)) AS parent_company,
            UPPER(TRIM(region_standardized)) AS region_standardized,
            ROW_NUMBER() OVER (PARTITION BY TRIM(customer_id) ORDER BY customer_id) rn
        FROM EG_ENV_SALES_PREP_DB.INGRESS.customer_master_stg
    )
    WHERE rn = 1
) src
ON tgt.customer_id = src.customer_id

WHEN MATCHED THEN UPDATE SET
    master_customer_name = src.master_customer_name,
    parent_company = src.parent_company,
    region_standardized = src.region_standardized

WHEN NOT MATCHED THEN INSERT (
    customer_master_key, customer_id, master_customer_name, parent_company, region_standardized
)
VALUES (
    seq_customer_master_key.NEXTVAL,
    src.customer_id, src.master_customer_name,
    src.parent_company, src.region_standardized
);

RETURN 'dim_customer_master loaded';

END;
$$;


CREATE OR REPLACE PROCEDURE EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_dim_products()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

MERGE INTO dim_products tgt
USING (
    SELECT *
    FROM (
        SELECT
            TRIM(product_id) AS product_id,
            INITCAP(TRIM(product_name)) AS product_name,
            INITCAP(TRIM(category)) AS category,
            TRY_TO_NUMBER(price,10,2) AS price,
            ROW_NUMBER() OVER (
                PARTITION BY TRIM(product_id)
                ORDER BY TRY_TO_NUMBER(price,10,2) DESC
            ) rn
        FROM EG_ENV_SALES_PREP_DB.INGRESS.products_stg
        WHERE TRY_TO_NUMBER(price) IS NOT NULL
    )
    WHERE rn = 1
) src
ON tgt.product_id = src.product_id

WHEN MATCHED THEN UPDATE SET
    product_name = src.product_name,
    category = src.category,
    price = src.price

WHEN NOT MATCHED THEN INSERT (
    product_key, product_id, product_name, category, price
)
VALUES (
    seq_product_key.NEXTVAL,
    src.product_id, src.product_name, src.category, src.price
);

RETURN 'dim_products loaded';

END;
$$;


CREATE OR REPLACE PROCEDURE EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_dim_date()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

INSERT INTO EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_date
WITH dates AS (
    SELECT 
        SEQ4() AS seq, 
        DATEADD(DAY, seq4(), '2020-01-01') AS dt
    FROM TABLE(GENERATOR(ROWCOUNT => 365*5))  -- 5 years of dates
)
SELECT
    TO_NUMBER(TO_CHAR(dt,'YYYYMMDD')) AS date_key,
    dt AS full_date,
    DAY(dt) AS day,
    MONTH(dt) AS month,
    YEAR(dt) AS year,
    QUARTER(dt) AS quarter,
    DAYOFWEEK(dt) AS day_of_week,
    MONTHNAME(dt) AS month_name,
    CASE WHEN DAYOFWEEK(dt) IN (1,7) THEN TRUE ELSE FALSE END AS is_weekend,
    CASE WHEN MONTH(dt) >= 4 THEN YEAR(dt)+1 ELSE YEAR(dt) END AS fiscal_year,   -- Example fiscal year starts April
    CASE WHEN MONTH(dt) IN (4,5,6) THEN 1
         WHEN MONTH(dt) IN (7,8,9) THEN 2
         WHEN MONTH(dt) IN (10,11,12) THEN 3
         ELSE 4 END AS fiscal_quarter
FROM dates;

RETURN 'dim_date loaded';

END;
$$;


CREATE OR REPLACE PROCEDURE EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_fact_opportunities()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

MERGE INTO EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_opportunities tgt
USING (
    SELECT *
    FROM (
        SELECT
            TRIM(o.opportunity_id) AS opportunity_id,
            c.customer_key,
            INITCAP(TRIM(o.stage)) AS stage,
            TRY_TO_NUMBER(o.amount,12,2) AS amount,
            crd.date_key AS created_date_key,
            cld.date_key AS close_date_key,
            ROW_NUMBER() OVER (
                PARTITION BY TRIM(o.opportunity_id)
                ORDER BY TRY_TO_DATE(o.created_date) DESC
            ) rn
        FROM EG_ENV_SALES_PREP_DB.INGRESS.opportunities_stg o
        JOIN EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customers c 
            ON TRIM(o.customer_id) = c.customer_id
        LEFT JOIN EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_date crd
            ON TRY_TO_DATE(o.created_date) = crd.full_date
        LEFT JOIN EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_date cld
            ON TRY_TO_DATE(o.close_date) = cld.full_date
        WHERE TRY_TO_NUMBER(o.amount) IS NOT NULL
    )
    WHERE rn = 1
) src
ON tgt.opportunity_id = src.opportunity_id

WHEN MATCHED THEN UPDATE SET
    customer_key = src.customer_key,
    stage = src.stage,
    amount = src.amount,
    created_date_key = src.created_date_key,
    close_date_key = src.close_date_key

WHEN NOT MATCHED THEN INSERT (
    opportunity_key, opportunity_id, customer_key, stage, amount, created_date_key, close_date_key
)
VALUES (
    seq_opportunity_key.NEXTVAL,
    src.opportunity_id, src.customer_key, src.stage,
    src.amount, src.created_date_key, src.close_date_key
);

RETURN 'fact_opportunities loaded';

END;
$$;


CREATE OR REPLACE PROCEDURE EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_fact_orders()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

MERGE INTO EG_ENV_SALES_PREP_DB.BASE_MODEL.fact_orders tgt
USING (
    SELECT *
    FROM (
        SELECT
            TRIM(o.order_id) AS order_id,
            c.customer_key,
            p.product_key,
            od.date_key AS order_date_key,
            TRY_TO_NUMBER(o.revenue,12,2) AS revenue,
            ROW_NUMBER() OVER (
                PARTITION BY TRIM(o.order_id)
                ORDER BY TRY_TO_DATE(o.order_date) DESC
            ) rn
        FROM EG_ENV_SALES_PREP_DB.INGRESS.orders_stg o
        JOIN EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_customers c 
            ON TRIM(o.customer_id) = c.customer_id
        JOIN EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_products p 
            ON TRIM(o.product_id) = p.product_id
        LEFT JOIN EG_ENV_SALES_PREP_DB.BASE_MODEL.dim_date od
            ON TRY_TO_DATE(o.order_date) = od.full_date
        WHERE TRY_TO_NUMBER(o.revenue) IS NOT NULL
    )
    WHERE rn = 1
) src
ON tgt.order_id = src.order_id

WHEN MATCHED THEN UPDATE SET
    customer_key = src.customer_key,
    product_key = src.product_key,
    order_date_key = src.order_date_key,
    revenue = src.revenue

WHEN NOT MATCHED THEN INSERT (
    order_key, order_id, customer_key, product_key, order_date_key, revenue
)
VALUES (
    seq_order_key.NEXTVAL,
    src.order_id, src.customer_key, src.product_key,
    src.order_date_key, src.revenue
);

RETURN 'fact_orders loaded';

END;
$$;


CALL EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_dim_customers();
CALL EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_dim_customer_master();
CALL EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_dim_products();
CALL EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_dim_date();
CALL EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_fact_opportunities();
CALL EG_ENV_SALES_PREP_DB.BASE_MODEL.sp_load_fact_orders();
