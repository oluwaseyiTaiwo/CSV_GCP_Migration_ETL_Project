
  
    

    create or replace table `csv-gcp-migration-etl-project`.`retail`.`product_dimention_table`
    
    

    OPTIONS()
    as (
      SELECT DISTINCT
    to_hex(md5(cast(coalesce(cast(StockCode as STRING), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(Description as STRING), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(UnitPrice as STRING), '_dbt_utils_surrogate_key_null_') as STRING))) as product_id,
		StockCode AS stock_code,
    Description AS description,
    UnitPrice AS price

FROM `csv-gcp-migration-etl-project`.`retail`.`raw_retail_data`
WHERE StockCode IS NOT NULL AND UnitPrice > 0
    );
  