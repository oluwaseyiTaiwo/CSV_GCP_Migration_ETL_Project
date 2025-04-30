WITH fact_invoices_data AS (
    SELECT
        InvoiceNo AS invoice_id,
        InvoiceDate AS datetime_id,
        to_hex(md5(cast(coalesce(cast(StockCode as STRING), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(Description as STRING), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(UnitPrice as STRING), '_dbt_utils_surrogate_key_null_') as STRING))) as product_id,
        to_hex(md5(cast(coalesce(cast(CustomerID as STRING), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(Country as STRING), '_dbt_utils_surrogate_key_null_') as STRING))) as customer_id,
        Quantity AS quantity,
        Quantity * UnitPrice AS total
FROM `csv-gcp-migration-etl-project`.`retail`.`raw_retail_data`
    WHERE Quantity > 0
)

SELECT
    invoice_id,
    datetime_dimention_table.datetime_id,
    product_dimention_table.product_id,
    customer_dimention_table.customer_id,
    quantity,
    total

FROM fact_invoices_data
INNER JOIN `csv-gcp-migration-etl-project`.`retail`.`datetime_dimention_table` as datetime_dimention_table ON fact_invoices_data.datetime_id = datetime_dimention_table.datetime_id
INNER JOIN `csv-gcp-migration-etl-project`.`retail`.`product_dimention_table` as product_dimention_table ON fact_invoices_data.product_id = product_dimention_table.product_id
INNER JOIN `csv-gcp-migration-etl-project`.`retail`.`customer_dimention_table` as customer_dimention_table ON fact_invoices_data.customer_id = customer_dimention_table.customer_id