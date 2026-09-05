# Apache Airflow DAGs

## DAG: consolidate_sales_dag

Консолидация из 2 дочерних компаний.

### Задачи

1. delete_old_data → DELETE за текущий день
2. load_child_1 → INSERT из child_1 (параллельно)
3. load_child_2 → INSERT из child_2 (параллельно)
4. deduplication → Удалить дубликаты
5. quality_check → Проверить качество
6. refresh_materialized_view → Обновить представление

### Schedule

Ежедневно в 06:00 UTC

### Retry

3 попытки каждые 5 минут
