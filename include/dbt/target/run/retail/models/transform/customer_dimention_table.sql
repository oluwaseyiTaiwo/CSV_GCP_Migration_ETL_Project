
  
    

    create or replace table `csv-gcp-migration-etl-project`.`retail`.`customer_dimention_table`
    
    

    OPTIONS()
    as (
      WITH customer_data AS (
	SELECT DISTINCT
	    to_hex(md5(cast(coalesce(cast(CustomerID as STRING), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(Country as STRING), '_dbt_utils_surrogate_key_null_') as STRING))) as customer_id, --Builds a surrogate key (a stable fake ID) using CustomerID + Country
	    Country AS country
	FROM `csv-gcp-migration-etl-project`.`retail`.`raw_retail_data`
	WHERE CustomerID IS NOT NULL
)

SELECT
    customer_table.*,    -- get customer_id and country
	Country_data.iso  -- add country ISO code
FROM customer_data as customer_table
LEFT JOIN `csv-gcp-migration-etl-project`.`retail`.`raw_country_data` as Country_data ON customer_table.country = Country_data.nicename
    );
  