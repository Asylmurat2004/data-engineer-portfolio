from airflow import DAG
from airflow.operators.postgres_operator import PostgresOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

default_args = {
    'owner': 'data-team',
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'consolidate_sales_dag',
    default_args=default_args,
    description='Consolidate sales from 2 child companies',
    schedule_interval='0 6 * * *',
    start_date=days_ago(1),
    catchup=False,
)

delete_old_data = PostgresOperator(
    task_id='delete_old_data',
    postgres_conn_id='postgres_prod',
    sql='DELETE FROM dw.fact_sales WHERE transaction_date = CURRENT_DATE;',
    dag=dag,
)

load_child_1 = PostgresOperator(
    task_id='load_child_1',
    postgres_conn_id='postgres_prod',
    sql='''
    INSERT INTO dw.fact_sales (sale_id, company_id, transaction_date, amount, product_id, status, loaded_at)
    SELECT transaction_id::BIGINT, 1, date::date, amount, product_id, status, NOW()
    FROM sources.sales_child_1
    WHERE date::date = CURRENT_DATE;
    ''',
    dag=dag,
)

load_child_2 = PostgresOperator(
    task_id='load_child_2',
    postgres_conn_id='postgres_prod',
    sql='''
    INSERT INTO dw.fact_sales (sale_id, company_id, transaction_date, amount, product_id, status, loaded_at)
    SELECT order_id, 2, created_at::date, sum, item_id, state, NOW()
    FROM sources.sales_child_2
    WHERE created_at::date = CURRENT_DATE;
    ''',
    dag=dag,
)

deduplication = PostgresOperator(
    task_id='deduplication',
    postgres_conn_id='postgres_prod',
    sql='''
    WITH duplicates AS (
      SELECT transaction_id, ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY loaded_at DESC) as rn
      FROM dw.fact_sales
    )
    DELETE FROM dw.fact_sales WHERE transaction_id IN (SELECT transaction_id FROM duplicates WHERE rn > 1);
    ''',
    dag=dag,
)

quality_check = PostgresOperator(
    task_id='quality_check',
    postgres_conn_id='postgres_prod',
    sql='SELECT COUNT(*) FROM dw.fact_sales WHERE transaction_id IS NULL;',
    dag=dag,
)

refresh_view = PostgresOperator(
    task_id='refresh_materialized_view',
    postgres_conn_id='postgres_prod',
    sql='REFRESH MATERIALIZED VIEW CONCURRENTLY dw.sales_daily_summary;',
    dag=dag,
)

delete_old_data >> [load_child_1, load_child_2] >> deduplication >> quality_check >> refresh_view
