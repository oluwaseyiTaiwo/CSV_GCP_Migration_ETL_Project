# Enhanced and corrected README with user's real file and task names
final_readme = """
# 🛒 CSV to GCP Retail ETL Project

This project demonstrates a complete ETL pipeline built using Apache Airflow, Google Cloud Platform (GCP), dbt, and Soda Core. It ingests raw CSV data into Google Cloud Storage, loads it into BigQuery, transforms it into a star schema using dbt, and validates both raw and transformed data using Soda.

---

## 📌 Project Summary

- **Project Title**: CSV to GCP Retail ETL Migration
- **Tools Used**: Airflow, GCS, BigQuery, dbt, Soda Core, Docker, Astro CLI
- **Pipeline**: Local CSV → GCS → BigQuery (raw) → dbt (transformation) → BigQuery (modeled) → Soda validation

---

## 🧠 What I Did

- Set up a Dockerized Airflow environment using Astronomer runtime.
- Created an Airflow DAG (`retail.py`) that:
  - Uploads `Online_Retail.csv` and `country_data.csv` to GCS
  - Loads the files into `raw_retail_data` and `raw_country_data` tables in BigQuery
  - Runs Soda checks to validate raw schema and values
  - Executes dbt transformations to create a star schema
  - Performs data quality checks post-transformation
- Designed dimension and fact tables in dbt: `customer_dimention_table`, `product_dimention_table`, `datetime_dimention_table`, `Retail_invoice_fact_table`
- Used Soda Core to ensure high data integrity throughout
- Prepared the system for integration with Metabase for future dashboarding

---

## 🔄 Pipeline Flow (Airflow DAG Overview)

### 1. Upload to GCS
- `Online_Retail.csv` → `raw/Online_Retail.csv`
- `country_data.csv` → `raw/country_data.csv`

### 2. Load to BigQuery
- `raw/Online_Retail.csv` → `retail.raw_retail_data`
- `raw/country_data.csv` → `retail.raw_country_data`

### 3. Raw Data Quality Checks
- Performed using `run_load_data_quality_checks()`
- Checks schema, nulls, data types

### 4. Data Transformation via dbt
- `customer_dimention_table.sql`: Builds customer_id and adds ISO codes
- `product_dimention_table.sql`: Deduplicates and filters product data
- `datetime_dimention_table.sql`: Extracts time parts from `InvoiceDate`
- `Retail_invoice_fact_table.sql`: Combines all keys and computes invoice totals

### 5. Post-Transformation Data Validation
- Performed using `run_transform_data_quality_checks()`
- Verifies uniqueness, null handling, and logical constraints

---

## 🛠️ Tech Stack

| Tool      | Purpose                                |
|-----------|----------------------------------------|
| Airflow   | Orchestrating ETL workflows            |
| GCS       | Cloud-based raw data storage           |
| BigQuery  | Scalable cloud data warehouse          |
| dbt       | SQL-based data modeling                |
| Soda Core | Data validation and quality monitoring |
| Docker    | Local development environment          |
| Astro CLI | Manages and deploys Airflow projects   |

---

## 📊 Data Models Overview

### `customer_dimention_table`
- Creates `customer_id` from `CustomerID + Country`
- Adds country ISO from `raw_country_data`

### `product_dimention_table`
- Unique `product_id` from `StockCode + Description + UnitPrice`
- Filters for valid products only

### `datetime_dimention_table`
- Parses multiple `InvoiceDate` formats
- Extracts year, month, day, hour, minute, weekday

### `Retail_invoice_fact_table`
- Joins all dimensions and computes invoice totals
- Surrogate keys ensure consistency across joins

---

## ✅ Soda Checks Summary

| Table                           | Check Types                                  |
|---------------------------------|-----------------------------------------------|
| `raw_retail_data`               | Schema validation, missing values, data types |
| `customer_dimention_table`      | Uniqueness, null checks, schema integrity     |
| `product_dimention_table`       | Non-negative pricing, duplicates              |
| `datetime_dimention_table`      | Weekday ranges, null handling                 |
| `Retail_invoice_fact_table`     | Positive total amounts, referential integrity |
---


# 🧪 How to Run
# Start development environment
- astro dev start

# Run Airflow task
- airflow tasks test retail upload_retail_csv_to_gcs 2025-01-01

# Run dbt models
- source /usr/local/airflow/dbt_venv/bin/activate
- cd include/dbt
- dbt run --profiles-dir /usr/local/airflow/include/dbt/

# Run Soda validation
- source /usr/local/airflow/soda_venv/bin/activate
- soda scan -d retail -c include/soda/configuration.yml include/soda/checks/*


# 🎯 Final Outcome
- ✅ Successfully ingested and modeled retail data from CSVs into BigQuery
- ✅ Implemented a robust, reusable Airflow DAG for data orchestration
- ✅ Built dimensional data models using dbt following best practices
- ✅ Ensured high data quality using Soda Core validations
- ✅ Created analytics-ready tables for future reporting and BI dashboards