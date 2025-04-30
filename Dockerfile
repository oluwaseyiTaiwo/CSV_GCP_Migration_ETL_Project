FROM quay.io/astronomer/astro-runtime:12.7.1

# Install system dependencies for building Python packages
USER root
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    && apt-get clean

# Set Python 3.11 as the default Python
RUN ln -sf /usr/bin/python3.11 /usr/bin/python

# Switch back to the Astro user
USER astro

# Create and install into the soda virtual environment
RUN python -m venv soda_venv && \
    ./soda_venv/bin/pip install --no-cache-dir \
        soda-core-bigquery \
        soda-core-scientific \
        apache-airflow-providers-google \
        pendulum

# Create and install into the dbt virtual environment
RUN python -m venv dbt_venv && \
    ./dbt_venv/bin/pip install --no-cache-dir \
        dbt-bigquery==1.5.3 \
        pendulum \
        apache-airflow-providers-google