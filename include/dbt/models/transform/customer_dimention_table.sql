WITH customer_data AS (
	SELECT DISTINCT
	    {{ dbt_utils.generate_surrogate_key(['CustomerID', 'Country']) }} as customer_id, --Builds a surrogate key (a stable fake ID) using CustomerID + Country
	    Country AS country
	FROM {{ source('retail', 'raw_retail_data') }}
	WHERE CustomerID IS NOT NULL
)

SELECT
    customer_table.*,    -- get customer_id and country
	Country_data.iso  -- add country ISO code
FROM customer_data as customer_table
LEFT JOIN {{ source('retail', 'raw_country_data') }} as Country_data ON customer_table.country = Country_data.nicename
