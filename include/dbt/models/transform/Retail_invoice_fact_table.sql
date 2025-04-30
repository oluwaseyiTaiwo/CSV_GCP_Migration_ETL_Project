WITH fact_invoices_data AS (
    SELECT
        InvoiceNo AS invoice_id,
        InvoiceDate AS datetime_id,
        {{ dbt_utils.generate_surrogate_key(['StockCode', 'Description', 'UnitPrice']) }} as product_id,
        {{ dbt_utils.generate_surrogate_key(['CustomerID', 'Country']) }} as customer_id,
        Quantity AS quantity,
        Quantity * UnitPrice AS total
FROM {{ source('retail', 'raw_retail_data') }}
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
INNER JOIN {{ ref('datetime_dimention_table') }} as datetime_dimention_table ON fact_invoices_data.datetime_id = datetime_dimention_table.datetime_id
INNER JOIN {{ ref('product_dimention_table') }} as product_dimention_table ON fact_invoices_data.product_id = product_dimention_table.product_id
INNER JOIN {{ ref('customer_dimention_table') }} as customer_dimention_table ON fact_invoices_data.customer_id = customer_dimention_table.customer_id