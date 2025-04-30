WITH datetime_data AS (
  SELECT DISTINCT
    InvoiceDate AS datetime_id,
    CASE
        WHEN LENGTH(InvoiceDate) = 16 THEN
            PARSE_DATETIME('%m/%d/%Y %H:%M', InvoiceDate)   -- "MM/DD/YYYY HH:MM"  %Y = 4-digit year (e.g. 2023)  "12/01/2010 08:26"
        WHEN LENGTH(InvoiceDate) <= 14 THEN
            PARSE_DATETIME('%m/%d/%y %H:%M', InvoiceDate)  -- "MM/DD/YY HH:MM"     %y = 2-digit year (e.g. 23 → 2023, 10 → 2010)    "12/1/10 8:26"
        ELSE
            NULL
    END AS date_part

  FROM `csv-gcp-migration-etl-project`.`retail`.`raw_retail_data`
  WHERE InvoiceDate IS NOT NULL
)


SELECT
  datetime_id,
  date_part as datetime,
  EXTRACT(YEAR FROM date_part) AS year,
  EXTRACT(MONTH FROM date_part) AS month,
  EXTRACT(DAY FROM date_part) AS day,
  EXTRACT(HOUR FROM date_part) AS hour,
  EXTRACT(MINUTE FROM date_part) AS minute,
  EXTRACT(DAYOFWEEK FROM date_part) AS weekday
FROM datetime_data