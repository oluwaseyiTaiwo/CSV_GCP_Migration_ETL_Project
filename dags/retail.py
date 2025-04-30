from airflow.decorators import dag, task
from datetime import datetime
from airflow.providers.google.cloud.transfers.local_to_gcs import LocalFilesystemToGCSOperator
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateEmptyDatasetOperator

from astro import sql as aql
from astro.files import File
from astro.sql.table import Table, Metadata
from astro.constants import FileType
from airflow.models.baseoperator import chain

from include.dbt.cosmos_config import DBT_PROJECT_CONFIG, DBT_CONFIG
from cosmos.airflow.task_group import DbtTaskGroup
from cosmos.constants import LoadMode
from cosmos.config import ProjectConfig, RenderConfig


@dag(
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=["CSV-GCP-RETAIL-MIGRATION"],
)
def retail():

    create_retail_bigquery_dataset = BigQueryCreateEmptyDatasetOperator(
        task_id="create_retail_dataset",
        dataset_id="retail",
        gcp_conn_id="GCP",
    )
     
    upload_retail_csv_to_gcs = LocalFilesystemToGCSOperator(
        task_id="upload_retail_csv_to_gcs",
        src="/usr/local/airflow/include/dataset/Online_Retail.csv",
        dst="raw/Online_Retail.csv",
        bucket="csv-gcp-migration-airflow-storage",
        gcp_conn_id="GCP",
        mime_type="text/csv",
    )

    load_retail_csv_to_bq_table = aql.load_file(
        task_id="load_retail_csv_to_bq_table",
        input_file=File(
            "gs://csv-gcp-migration-airflow-storage/raw/Online_Retail.csv",
            filetype=FileType.CSV,
            conn_id="GCP",
        ),
        output_table=Table(
            name="raw_retail_data",
            conn_id="GCP",
            metadata=Metadata(schema="retail")
        ),
        use_native_support=False
    )
    upload_country_csv_to_gcs = LocalFilesystemToGCSOperator(
            task_id="upload_country_data_csv_to_gcs",
            src="/usr/local/airflow/include/dataset/country_data.csv",
            dst="raw/country_data.csv",
            bucket="csv-gcp-migration-airflow-storage",
            gcp_conn_id="GCP",
            mime_type="text/csv",
        )

    load_country_csv_to_bq_table = aql.load_file(
        task_id="load_country_data_csv_to_bq_table",
        input_file=File(
            "gs://csv-gcp-migration-airflow-storage/raw/country_data.csv",
            filetype=FileType.CSV,
            conn_id="GCP",
        ),
        output_table=Table(
            name="raw_country_data",
            conn_id="GCP",
            metadata=Metadata(schema="retail")
        ),
        use_native_support=False
    )


    @task.external_python(python='/usr/local/airflow/soda_venv/bin/python')
    def run_load_data_quality_checks(scan_name='check_load', checks_subpath='sources'):
        from include.soda.check_function import check
        return check(scan_name, checks_subpath)

    


    transform = DbtTaskGroup(
        group_id='transform',
        project_config=DBT_PROJECT_CONFIG,
        profile_config=DBT_CONFIG,
        render_config=RenderConfig(load_method=LoadMode.DBT_LS,select=['path:models/transform'])
    )

    @task.external_python(python='/usr/local/airflow/soda_venv/bin/python')
    def run_transform_data_quality_checks(scan_name='check_transform', checks_subpath='transform'):
        from include.soda.check_function import check

        return check(scan_name, checks_subpath)

    

    chain(
        create_retail_bigquery_dataset,
        upload_retail_csv_to_gcs,
        load_retail_csv_to_bq_table,
        upload_country_csv_to_gcs,
        load_country_csv_to_bq_table,
        run_load_data_quality_checks(),
        transform,
        run_transform_data_quality_checks()
    )
retail()
